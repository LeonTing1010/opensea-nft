// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IRandomConsumer.sol";
import "./RandomNumberGenerator.sol";

contract Lottery is IRandomConsumer, Ownable, AccessControl {
    using Address for address;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    bytes32 public constant LOTTERY_ROLE = keccak256("LOTTERY_ROLE");
    enum LotteryState {
        Open,
        Closed,
        Finished
    }
    struct Prizes {
        uint8 count;
        uint256 prize;
    }

    struct Winner {
        uint256 ticket;
        uint256 prize;
        address star;
        uint8 loc;
    }
    Prizes[] cps;
    // Winner[] ws;
    uint256 public numberOfTickets;
    EnumerableSet.AddressSet private stars;
    mapping(address => uint256[]) tickets;
    mapping(uint256 => address) ticket2stars;
    mapping(uint256 => Winner) wners; // ticket>winner

    LotteryState public state;

    uint256 public immutable phase;

    uint256[] public winningNumbers;
    uint256 private randomNumberRequestId;
    address public rng;

    event LotteryStateChanged(LotteryState newState);
    event NumberGeneratorChanged(address oldGenerator, address newGenerator);
    event NewEntry(address indexed player, uint256 tokenId, uint256 amount);
    event NumberRequested(uint256 requestId);
    event NumberDrawn(uint256 requestId, uint256 winningNumber);

    event PrizeReceived(address indexed to, uint256 prize);
    event Received(address sender, uint256 value);

    //modifiers
    modifier isState(LotteryState _state) {
        require(state == _state, "Lottery: Wrong state for this action");
        _;
    }

    modifier onlyRandomGenerator() {
        require(msg.sender == rng, "Lottery: Must be correct generator");
        _;
    }

    //constructor
    constructor(uint256 _phase) {
        phase = _phase;
        _changeState(LotteryState.Open);
        _setupRole(LOTTERY_ROLE, msg.sender);
    }

    //functions
    //onlyOwner
    function grantLotteryRole(address star) external onlyOwner {
        _grantRole(LOTTERY_ROLE, star);
    }

    function twist(
        address _star,
        uint256 _amount,
        uint256 tokenId
    ) public isState(LotteryState.Open) onlyRole(LOTTERY_ROLE) {
        require(_amount > 0, "Lottery: amount must be greater than 0");
        for (uint256 i = 0; i < _amount; i++) {
            tickets[_star].push(numberOfTickets);
            ticket2stars[numberOfTickets] = _star;
            numberOfTickets = numberOfTickets.add(1);
        }
        stars.add(_star);
        emit NewEntry(_star, tokenId, _amount);
    }

    function getStar(uint256 _ticketNo) external view returns (address) {
        return ticket2stars[_ticketNo];
    }

    function setWinnings(uint8[] calldata _numbers, uint256[] calldata _prizes)
        external
        isState(LotteryState.Open)
        onlyRole(LOTTERY_ROLE)
    {
        require(
            _numbers.length == _prizes.length,
            "Lottery: The two arrays have different lengths"
        );
        for (uint256 index = 0; index < _numbers.length; index++) {
            cps.push(Prizes(_numbers[index], _prizes[index]));
        }
    }

    function getWinner(uint256 _ticketNo)
        external
        view
        returns (
            address star,
            uint8 loc,
            uint256 prize,
            uint256 ticket
        )
    {
        Winner memory w = wners[_ticketNo];
        return (w.star, w.loc, w.prize, w.ticket);
    }

    function winners() external view returns (Winner[] memory) {
        uint256 wc = 0;
        for (uint256 index = 0; index < cps.length; index++) {
            wc = wc.add(cps[index].count);
        }
        uint256 wi = 0;
        Winner[] memory ws = new Winner[](wc);
        bool[] memory sets = new bool[](numberOfTickets);
        for (
            uint256 index = 0;
            index < winningNumbers.length && wi < wc;
            index++
        ) {
            uint256 wn = winningNumbers[index];

            if (wners[wn].loc > 0 && !sets[wn]) {
                sets[wn] = true;
                ws[wi] = wners[wn];
                wi = wi.add(1);
            }
        }
        return ws;
    }

    function winning()
        external
        onlyRole(LOTTERY_ROLE)
        isState(LotteryState.Finished)
    {
        uint256 loc = 0;
        for (uint256 pi = 0; pi < cps.length; pi++) {
            for (uint256 ci = 0; ci < cps[pi].count; ci++) {
                while (loc < winningNumbers.length) {
                    uint256 wn = winningNumbers[loc];
                    if (wners[wn].loc == 0) {
                        wners[wn] = Winner(
                            wn,
                            cps[pi].prize,
                            ticket2stars[wn],
                            uint8(pi + 1)
                        );
                        // ws.push(wners[wn]);
                        break;
                    }
                    loc = loc.add(1);
                }
            }
        }
    }

    function setRandomNumberGenerator(address _rng)
        external
        onlyRole(LOTTERY_ROLE)
    {
        require(_rng != address(0), "Lottery: Invalid generator");
        emit NumberGeneratorChanged(rng, _rng);
        rng = _rng;
    }

    function getStars() external view returns (address[] memory) {
        return stars.values();
    }

    function getTickets(address star) external view returns (uint256[] memory) {
        return tickets[star];
    }

    function draw() external onlyRole(LOTTERY_ROLE) isState(LotteryState.Open) {
        require(numberOfTickets > 0, "Lottery: Nobody holds a ticket");
        require(cps.length > 0, "Lottery: Please set the number of prizes");
        _changeState(LotteryState.Closed);
        randomNumberRequestId = RandomNumberGenerator(rng).requestRandomWords();
        emit NumberRequested(randomNumberRequestId);
    }

    // function rollover() public onlyOwner isState(LotteryState.Finished) {
    //     //rollover new lottery
    // }

    function onRandomWords(
        uint256 _randomNumberRequestId,
        uint256[] memory _randomWords
    ) external override onlyRandomGenerator isState(LotteryState.Closed) {
        if (_randomNumberRequestId == randomNumberRequestId) {
            _changeState(LotteryState.Finished);
            //winningNumbers = _randomWords;
            for (uint256 index = 0; index < _randomWords.length; index++) {
                winningNumbers.push(_randomWords[index] % numberOfTickets);
            }
            emit NumberDrawn(_randomNumberRequestId, winningNumbers.length);
        }
    }

    function _changeState(LotteryState _newState) private {
        state = _newState;
        emit LotteryStateChanged(state);
    }

    function transferRNG(address lottery)
        external
        onlyRole(LOTTERY_ROLE)
        isState(LotteryState.Finished)
    {
        RandomNumberGenerator(rng).transferOwnership(lottery);
        Lottery(lottery).setRandomNumberGenerator(rng);
    }

    // Function to receive Ether. msg.data must be empty
    // receive() external payable isState(LotteryState.Open) {
    //     emit Received(msg.sender, msg.value);
    // }
}
