// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Lottery.sol";

contract WelfareFoctory is Ownable {
    mapping(uint256 => address) phases;
    uint64 subId;
    address vrfCoordinator;
    bytes32 keyHash;

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

    function newLottery(uint256 phase, uint8 bits)
        external
        onlyOwner
        returns (address)
    {
        require(phases[phase] == address(0), "Current lottery already exists");
        Lottery lottery = new Lottery(phase, subId, vrfCoordinator, keyHash);
        lottery.setBitMask(bits);
        lottery.transferOwnership(msg.sender);
        phases[phase] = address(lottery);
        emit NewLottery(address(lottery));
        return address(lottery);
    }

    function getLottery(uint256 phase) external view returns (address) {
        return phases[phase];
    }
}
