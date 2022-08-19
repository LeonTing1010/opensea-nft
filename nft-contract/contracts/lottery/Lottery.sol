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
    uint256 private constant _BITPOS_LOTTERY_ENTRY = (1 << 4) - 1;
    // uint256 private _BITMASK_LOTTERY_ENTRY = (1 << 28) - 1;
    uint8 private _BITPOS = 28;

    enum LotteryState {
        Open,
        Closed,
        Finished
    }
    struct Ticket {
        uint256 number;
        address star;
    }
    struct Winning {
        address star;
        uint8 ws;
        uint256 prize;
    }
    uint256 public numberOfTickets;
    EnumerableSet.AddressSet private stars;
    mapping(uint8 => uint256) proportions;
    mapping(address => uint256[]) tickets;
    mapping(uint256 => Winning) number2Winning;
    mapping(uint8 => Ticket[]) prize2Tickets;
    mapping(address => uint256) star2Prize;
    LotteryState public state;

    uint256 public winningNumber;
    uint256 private randomNumberRequestId;
    address public randomNumberGenerator;
    uint256 public phase;

    event LotteryStateChanged(LotteryState newState);
    event NumberGeneratorChanged(address generator);
    event NewEntry(address indexed player, uint256 number);
    event NumberRequested(uint256 requestId);
    event NumberDrawn(uint256 requestId, uint256 winningNumber);
    event BitMaskChanged(uint8 bits);
    event Prize(
        address indexed to,
        uint8 indexed ws,
        uint256 prize,
        uint256 number
    );
    event Received(address sender, uint256 value);

    //modifiers
    modifier isState(LotteryState _state) {
        require(state == _state, "Lottery: Wrong state for this action");
        _;
    }

    modifier onlyRandomGenerator() {
        require(
            msg.sender == randomNumberGenerator,
            "Lottery: Must be correct generator"
        );
        _;
    }

    //constructor
    constructor(uint256 _phase) {
        phase = _phase;

        _changeState(LotteryState.Open);
        _setupRole(LOTTERY_ROLE, msg.sender);
    }

    //functions
    function getWinning(uint256 ticketNo)
        external
        view
        returns (
            address,
            uint8,
            uint256
        )
    {
        return (
            number2Winning[ticketNo].star,
            number2Winning[ticketNo].ws,
            number2Winning[ticketNo].prize
        );
    }

    function getPrize(address star) external view returns (uint256) {
        return star2Prize[star];
    }

    //onlyOwner
    function grantLotteryRole(address star) external onlyOwner {
        _grantRole(LOTTERY_ROLE, star);
    }

    function twist(address _star, uint256 _amount)
        public
        isState(LotteryState.Open)
        onlyRole(LOTTERY_ROLE)
    {
        require(_amount > 0, "Lottery: Tickets must be greater than 0");
        for (uint256 i = 0; i < _amount; i++) {
            uint256 lot = uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        _star,
                        phase,
                        numberOfTickets
                    )
                )
            );
            numberOfTickets = numberOfTickets.add(1);
            tickets[_star].push(lot);
            emit NewEntry(_star, lot);
        }
        stars.add(_star);
    }

    function batchTwist(address[] calldata _stars, uint256[] calldata _amounts)
        external
        isState(LotteryState.Open)
        onlyRole(LOTTERY_ROLE)
    {
        require(
            _stars.length == _amounts.length,
            "Lottery: The two arrays have different lengths"
        );
        for (uint256 index = 0; index < _stars.length; index++) {
            twist(_stars[index], _amounts[index]);
        }
    }

    function _prize(uint256 _winningNum) private {
        // bits 1
        for (uint256 e = 0; e < stars.length(); e++) {
            address star = stars.at(e);
            uint256[] memory ts = tickets[star];
            for (uint256 t = 0; t < ts.length; t++) {
                uint256 mLot = ts[t];
                uint256 wLot = _winningNum;
                uint8 bits = _BITPOS;
                uint8 ws = 0;
                while (bits > 0) {
                    uint256 ml = mLot & _BITPOS_LOTTERY_ENTRY;
                    uint wl = wLot & _BITPOS_LOTTERY_ENTRY;
                    if (ml == wl) {
                        ws = ws + 1;
                    }
                    mLot = mLot >> 4;
                    wLot = wLot >> 4;
                    bits = bits - 4;
                }
                number2Winning[ts[t]] = Winning(star, ws, 0);
                if (ws > 0) {
                    prize2Tickets[ws].push(Ticket(ts[t], star));
                }
            }
        }
    }

    function _payout(uint256 _balance) private {
        uint8 length = _BITPOS / 4;
        for (uint8 pi = length; pi > 0; pi--) {
            uint256 p_len = prize2Tickets[pi].length;
            if (p_len > 0 && proportions[pi] > 0) {
                uint256 prize = _balance.mul(proportions[pi]).div(1 ether);
                if (prize > 0) {
                    _balance = _balance.sub(prize);
                    uint256 p = prize.div(p_len);
                    for (uint256 index = 0; index < p_len; index++) {
                        Ticket memory ticket = prize2Tickets[pi][index];
                        address star = ticket.star;
                        // payable(star).transfer(p);
                        uint256 number = ticket.number;
                        emit Prize(star, pi, p, number);
                        number2Winning[number].prize = p;
                        star2Prize[star] = star2Prize[star].add(p);
                    }
                }
            }
        }
        if (_balance > 0 && numberOfTickets > 0) {
            uint _left = _balance.div(numberOfTickets);
            for (uint256 index = 0; index < stars.length(); index++) {
                address star = stars.at(index);
                uint256 t_len = tickets[star].length;
                uint256 p = _left.mul(t_len);
                emit Prize(star, 0, p, t_len);
                star2Prize[star] = star2Prize[star].add(p);
                payable(star).transfer(star2Prize[star]);
            }
        }
    }

    function _payoutPrize(uint256 _winningNum) private {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            _prize(_winningNum);
            _payout(balance);
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
            uint256 prize = _prizes[index];
            require(stars.contains(star), "Lottery: Invalid star");
            (bool suc, uint256 sub) = balance.trySub(prize);
            require(suc, "Lottery: Insufficient balance");
            balance = sub;
            payable(star).transfer(prize);
        }
    }

    function setRandomNumberGenerator(address _randomNumberGenerator)
        external
        onlyOwner
    {
        require(
            _randomNumberGenerator != address(0),
            "Lottery: Invalid generator"
        );
        randomNumberGenerator = _randomNumberGenerator;
        emit NumberGeneratorChanged(randomNumberGenerator);
    }

    function setProportion(
        uint8[] calldata _luckyNos,
        uint256[] calldata _props
    ) external onlyOwner isState(LotteryState.Open) {
        require(
            _luckyNos.length == _props.length,
            "Lottery: The two arrays have different lengths"
        );
        require(
            _luckyNos.length == this.getLength(),
            "Lottery: Lucky numbers have inconsistent lengths"
        );
        uint256 sum;
        for (uint256 i = 0; i < _props.length; i++) {
            require(_luckyNos[i] > 0, "Lottery: Invalid lucky numbers");
            sum = sum + _props[i];
            require(sum <= 1 ether, "Lottery: Invalid proportion");
            proportions[_luckyNos[i]] = _props[i];
        }
    }

    function getProportion(uint8 _ws) external view returns (uint256) {
        return proportions[_ws];
    }

    function getLength() external view returns (uint256) {
        return _BITPOS / 4;
    }

    function setLength(uint8 _length)
        external
        onlyOwner
        isState(LotteryState.Open)
    {
        require(_length >= 1 && _length <= 84, "Lottery: Invalid length");
        _BITPOS = _length * 4;
        // _BITMASK_LOTTERY_ENTRY = (1 << _BITPOS) - 1;
        emit BitMaskChanged(_BITPOS);
    }

    function getStars() external view returns (address[] memory) {
        return stars.values();
    }

    function getTickets(address star) external view returns (uint256[] memory) {
        return tickets[star];
    }

    function draw() external onlyOwner isState(LotteryState.Open) {
        require(numberOfTickets > 0, "Lottery: Nobody holds a ticket");
        require(address(this).balance > 0, "Lottery: Insufficient balance");
        _changeState(LotteryState.Closed);
        randomNumberRequestId = RandomNumberGenerator(randomNumberGenerator)
            .requestRandomWords();
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
            winningNumber = _randomWords[0];
            emit NumberDrawn(_randomNumberRequestId, winningNumber);
        }
    }

    function payout() external isState(LotteryState.Finished) {
        _payoutPrize(winningNumber);
    }

    function _changeState(LotteryState _newState) private {
        state = _newState;
        emit LotteryStateChanged(state);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable isState(LotteryState.Open) {
        emit Received(msg.sender, msg.value);
    }

    function transferRNG(address payable lottery)
        external
        onlyOwner
        isState(LotteryState.Finished)
    {
        RandomNumberGenerator(randomNumberGenerator).transferOwnership(lottery);
        Lottery(lottery).setRandomNumberGenerator(randomNumberGenerator);
    }
}
