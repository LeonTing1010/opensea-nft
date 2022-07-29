// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Lottery.sol";

contract WelfareFoctory is Ownable {
    mapping(uint256 => address) phases;
    uint64 subId;
    address vrfCoordinator;
    bytes32 keyHash;
    uint256 public phase;

    event NewLottery(address lottery);

    constructor(
        uint64 _subscriptionId,
        address _vrfCoordinator,
        bytes32 _keyHash
    ) {
        subId = _subscriptionId;
        vrfCoordinator = _vrfCoordinator;
        keyHash = _keyHash;
    }

    function newLottery(uint8 _length) external onlyOwner returns (address) {
        phase = phase + 1;
        Lottery lottery = new Lottery(phase, subId, vrfCoordinator, keyHash);
        if (lottery.getLength() != _length) {
            lottery.setLength(_length);
        }
        lottery.transferOwnership(msg.sender);
        phases[phase] = address(lottery);
        emit NewLottery(address(lottery));
        return address(lottery);
    }

    function getLottery(uint256 _phase) external view returns (address) {
        return phases[_phase];
    }
}
