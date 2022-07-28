// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IRandomConsumer.sol";
import "./RandomNumberGenerator.sol";

contract Lottery is IRandomConsumer, Ownable {
    using Address for address;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint8 private _BITPOS = 8;
    uint256 private _BITMASK_LOTTERY_ENTRY = (1 << 8) - 1;
    uint256 private constant _BITPOS_LOTTERY_ENTRY = (1 << 4) - 1;
    enum LotteryState {
        Open,
        Closed,
        Finished
    }

    struct Entry {
        uint256[] numbers;
        uint256 bonus;
        uint8 winnings;
        bool finished;
    }
    mapping(uint8 => uint256) bonus;
    mapping(address => Entry) entries;
    EnumerableSet.AddressSet private stars;

    LotteryState public state;

    uint256 public winningNumber;
    uint256 public randomNumberRequestId;
    address public randomNumberGenerator;
    uint256 public phase;

    event LotteryStateChanged(LotteryState newState);
    event NewEntry(address player, uint256 number);
    event NumberRequested(uint256 requestId);
    event NumberDrawn(uint256 requestId, uint256 winningNumber);
    event BitMaskChanged(uint8 bits);
    event Bonus(uint256 phase, address from, address to, uint256 bonus);

    //modifiers
    modifier isState(LotteryState _state) {
        require(state == _state, "Wrong state for this action");
        _;
    }

    modifier onlyRandomGenerator() {
        require(
            msg.sender == randomNumberGenerator,
            "Must be correct generator"
        );
        _;
    }

    //constructor
    constructor(
        uint256 _phase,
        uint64 subscriptionId,
        address _vrfCoordinator,
        bytes32 _keyHash
    ) {
        phase = _phase;
        randomNumberGenerator = address(
            new RandomNumberGenerator(subscriptionId, _vrfCoordinator, _keyHash)
        );
        _changeState(LotteryState.Open);
    }

    //functions
    function setProportion(uint8 _ws, uint256 _proportion)
        public
        onlyOwner
        isState(LotteryState.Open)
    {
        require(_ws > 0, "Invalid bits of winning");
        require(_proportion <= 1 ether, "Invalid proportion");
        bonus[_ws] = _proportion;
    }

    function getProportion(uint8 _ws) public view returns (uint256) {
        return bonus[_ws];
    }

    function getBits() external view returns (uint256) {
        return _BITPOS % 4;
    }

    function setBitMask(uint8 _bits)
        public
        onlyOwner
        isState(LotteryState.Open)
    {
        require(_bits % 4 == 0 && _bits <= 256, "Invalid bytes");
        _BITPOS = _bits;
        _BITMASK_LOTTERY_ENTRY = (1 << _BITPOS) - 1;
        emit BitMaskChanged(_BITPOS);
    }

    function getStars() external view returns (address[] memory) {
        return stars.values();
    }

    function getLotterisByAddress(address star)
        external
        view
        returns (uint256[] memory)
    {
        return entries[star].numbers;
    }

    function getWiningsByAddress(address star) external view returns (uint256) {
        return entries[star].winnings;
    }

    function getBonusByAddress(address star) external view returns (uint256) {
        return entries[star].bonus;
    }

    function getFinishedByAddress(address star) external view returns (bool) {
        return entries[star].finished;
    }

    //onlyOwner
    function lottery() public isState(LotteryState.Open) returns (uint256) {
        uint256 lot = uint256(
            keccak256(
                abi.encodePacked(
                    block.difficulty,
                    block.timestamp,
                    msg.sender,
                    phase
                )
            )
        );
        entries[msg.sender].numbers.push(lot);
        stars.add(msg.sender);

        emit NewEntry(msg.sender, lot);
        return lot;
    }

    function drawWords() public onlyOwner isState(LotteryState.Open) {
        require(stars.length() > 0, "Nobody holds a lottery");
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
    ) public override onlyRandomGenerator isState(LotteryState.Closed) {
        if (_randomNumberRequestId == randomNumberRequestId) {
            _changeState(LotteryState.Finished);
            winningNumber = _randomWords[0];
            emit NumberDrawn(_randomNumberRequestId, winningNumber);
            _payoutBonus(winningNumber);
        }
    }

    function _payoutBonus(uint256 _winningNum) private {
        uint256 len = stars.length();
        // bits 1
        for (uint256 e = 0; e < len; e++) {
            address star = stars.at(e);
            Entry memory entry = entries[star];
            entry.winnings = 0;
            entry.bonus = 0;
            for (uint256 n = 0; n < entry.numbers.length; n++) {
                uint256 mLot = (entry.numbers[n] & _BITMASK_LOTTERY_ENTRY);
                uint256 wLot = (_winningNum & _BITMASK_LOTTERY_ENTRY);
                uint8 bits = _BITPOS;
                while (bits > 0) {
                    uint256 ml = mLot & _BITPOS_LOTTERY_ENTRY;
                    uint wl = wLot & _BITPOS_LOTTERY_ENTRY;
                    if (ml == wl) {
                        entry.winnings = entry.winnings + 1;
                    }
                    mLot = mLot >> 4;
                    wLot = wLot >> 4;
                    bits = bits - 4;
                }
                entries[star] = entry;
            }
        }
        uint256 balance = address(this).balance;
        if (balance > 0) {
            uint256 bigBonus = balance;
            // bonus
            for (uint256 index = 0; index < len && balance > 0; index++) {
                address star = stars.at(index);
                Entry memory entry = entries[star];
                uint256 _bonus = 0;
                uint8 bits = entry.winnings;
                if (bits > 0 && bonus[bits] > 0) {
                    _bonus = bigBonus.mul(bonus[bits]).div(1 ether);
                    if (_bonus > 0) {
                        entry.bonus = _bonus;
                        entries[star] = entry;
                        balance = balance.sub(_bonus);
                    }
                }
            }
            if (balance > 0) {
                // left balance
                uint _left = balance.div(len);
                for (uint256 index = 0; index < len; index++) {
                    Entry memory entry = entries[stars.at(index)];
                    entry.bonus = entry.bonus.add(_left);
                    entries[stars.at(index)] = entry;
                }
            }
            // payout
            for (uint256 index = 0; index < len; index++) {
                address star = stars.at(index);
                Entry memory entry = entries[star];
                if (entry.bonus > 0 && !entry.finished) {
                    uint256 _bonus = entry.bonus;
                    // entry.bonus = 0;
                    entry.finished = true;
                    entries[star] = entry;
                    payable(star).transfer(_bonus);
                    emit Bonus(phase, address(this), star, _bonus);
                }
            }
        }
    }

    function _changeState(LotteryState _newState) private {
        state = _newState;
        emit LotteryStateChanged(state);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}
}
