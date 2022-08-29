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
        address star;
        uint8 lev;
        uint256 ticket;
        uint256 prize;
    }
    Prizes[] cps;
    Winner[] ws;
    uint256 public numberOfTickets;
    EnumerableSet.AddressSet private stars;
    mapping(address => uint256[]) tickets;
    mapping(uint8 => Winner) wners;

    LotteryState public state;
    uint8 public immutable limit;
    uint256 phase;

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
    constructor(uint256 _phase, uint8 _limit) {
        require(_limit > 0, "Lottery: limit must be greater than 0");
        limit = _limit;
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
        for (uint256 i = 1; i <= _amount; i++) {
            numberOfTickets = numberOfTickets.add(i);
            tickets[_star].push(numberOfTickets);
        }
        stars.add(_star);
        emit NewEntry(_star, tokenId, _amount);
    }

    function getPrizes(uint256 _ticketNo)
        external
        view
        returns (uint256 prizes)
    {
        for (uint256 index = 0; index < limit; index++) {
            if (winningNumbers[index] % limit == _ticketNo % limit) {
                return index;
            }
        }
    }

    function getStar(uint256 _ticketNo) external view returns (address) {
        for (uint256 index = 0; index < stars.length(); index++) {
            address star = stars.at(index);
            uint256[] memory ts = tickets[star];
            for (uint256 ti = 0; ti < ts.length; ti++) {
                if (ts[ti] == _ticketNo) return star;
            }
        }
        return address(0);
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

    function winners() external view returns (Winner[] memory) {
        return ws;
    }

    function winning()
        external
        onlyRole(LOTTERY_ROLE)
        isState(LotteryState.Finished)
    {
        for (uint256 pi = 0; pi < cps.length; pi++) {
            for (uint256 ci = 0; ci < cps[pi].count; ci++) {
                for (
                    uint256 wi = 0;
                    wi < winningNumbers.length;
                    wi = wi + cps[pi].count
                ) {
                    uint8 wn = uint8(winningNumbers[wi + ci] % limit);
                    if (wners[wn].lev == 0) {
                        wners[wn] = Winner(
                            address(0),
                            uint8(pi + 1),
                            0,
                            cps[pi].prize
                        );
                    } else {
                        wi = wi + 1;
                    }
                }
            }
        }
        for (uint256 si = 0; si < stars.length(); si++) {
            address star = stars.at(si);
            uint256[] memory ts = tickets[star];
            for (uint256 ti = 0; ti < ts.length; ti++) {
                uint8 wn = uint8(ts[ti] % limit);
                wners[wn].star = star;
                wners[wn].ticket = ts[ti];
                ws.push(wners[wn]);
            }
        }
    }

    function payout(address[] calldata _stars, uint256[] calldata _prizes)
        external
        payable
        onlyOwner
        isState(LotteryState.Finished)
    {
        require(
            _stars.length == _prizes.length,
            "Lottery: The two arrays have different lengths"
        );
        uint256 balance = address(this).balance;
        for (uint256 index = 0; index < _stars.length && balance > 0; index++) {
            address star = _stars[index];
            uint256 _prize = _prizes[index];
            require(stars.contains(star), "Lottery: Invalid star");
            (bool suc, uint256 sub) = balance.trySub(_prize);
            require(suc, "Lottery: Insufficient balance");
            balance = sub;
            payable(star).transfer(_prize);
            emit PrizeReceived(star, _prize);
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
        require(address(this).balance > 0, "Lottery: Insufficient balance");
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
            winningNumbers = _randomWords;
            emit NumberDrawn(_randomNumberRequestId, winningNumbers.length);
        }
    }

    function _changeState(LotteryState _newState) private {
        state = _newState;
        emit LotteryStateChanged(state);
    }

    function transferRNG(address payable lottery)
        external
        onlyRole(LOTTERY_ROLE)
        isState(LotteryState.Finished)
    {
        RandomNumberGenerator(rng).transferOwnership(lottery);
        Lottery(lottery).setRandomNumberGenerator(rng);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable isState(LotteryState.Open) {
        emit Received(msg.sender, msg.value);
    }
}
