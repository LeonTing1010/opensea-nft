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

    uint256 private constant _BITMASK_LOTTERY_ENTRY = (1 << 4) - 1;

    enum LotteryState {
        Open,
        Closed,
        Finished
    }

    struct Entry {
        uint256[] numbers;
        uint256 winnings;
        bool bonus;
    }
    mapping(uint8 => uint256) bonus;
    mapping(address => Entry) entries;
    address[] public stars;
    LotteryState public state;
    uint256 public numberOfLotteries;
    uint256 public winningNumber;
    uint256 public randomNumberRequestId;
    address public randomNumberGenerator;

    event LotteryStateChanged(LotteryState newState);
    event NewEntry(address player, uint256 number);
    event NumberRequested(uint256 requestId);
    event NumberDrawn(uint256 requestId, uint256 winningNumber);

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
    constructor(address _randomConsumer) {
        randomNumberGenerator = _randomConsumer;
        _changeState(LotteryState.Open);
    }

    //functions

    function getLotterisByAddress(address star)
        external
        view
        returns (uint256[])
    {
        return entries[star];
    }

    //onlyOwner
    function lottery() public isState(LotteryState.Open) returns (uint256) {
        uint256 lot = uint256(
            keccak256(
                abi.encodePacked(block.difficulty, block.timestamp, msg.sender)
            )
        );
        entries[msg.sender].numbers.push(lot);
        stars.push(msg.sender);
        numberOfLotteries++;
        emit NewEntry(msg.sender, lot);
    }

    function drawWords() public onlyOwner isState(LotteryState.Open) {
        _changeState(LotteryState.Closed);
        randomNumberRequestId = RandomNumberGenerator(randomNumberGenerator)
            .requestRandomWords();
        emit NumberRequested(randomNumberRequestId);
    }

    function rollover() public onlyOwner isState(LotteryState.Finished) {
        //rollover new lottery
    }

    function onRandomWords(
        uint256 _randomNumberRequestId,
        uint256[] memory _randomWords
    ) public override onlyRandomGenerator isState(LotteryState.Closed) {
        if (_randomNumberRequestId == randomNumberRequestId) {
            _changeState(LotteryState.Finished);
            winningNumber = _randomWords[0];
            emit NumberDrawn(_randomNumberRequestId, winningNumber);
            _calBonus(winningNumber);
            _payout();
        }
    }

    // private
    function _payout() internal {
        // bonus
        for (uint256 index = 0; index < stars.length(); index++) {
            Entry entry = entries[stars[index]];
            if (entry.bonus > 0) {
                payable(stars[index]).transfer(entry.bonus);
            }
        }
    }

    function _calBonus(uint256 _winningNum) public {
        uint256 balance = address(this).balance;
        // bits 1
        for (uint256 e = 0; e < stars.length(); e++) {
            Entry entry = entries[stars[e]];
            for (uint256 n = 0; n < entry.numbers.length(); n++) {
                uint256 lot = (entry.numbers[n] & _BITMASK_LOTTERY_ENTRY) ^
                    (_winningNum & _BITMASK_LOTTERY_ENTRY);
                while (lot > 0) {
                    lot = lot & (lot - 1);
                    entry.winnings.add(1);
                }
            }
        }
        if (balance > 0) {
            uint256 len = stars.length();
            // bonus
            for (uint256 index = 0; index < len; index++) {
                Entry entry = entries[stars[index]];
                if (entry.winnings > 0) {
                    entry.bonus = balance.mul(
                        bonus[entry.winnings].div(10**18)
                    );
                    balance = balance.sub(entry.bonus);
                }
            }
            if (balance > 0) {
                // left balance
                for (uint256 index = 0; index < len; index++) {
                    entries[stars[index]].bonus.add(balance.div(len));
                }
            }
        }
    }

    function _changeState(LotteryState _newState) private {
        state = _newState;
        emit LotteryStateChanged(state);
    }
}
