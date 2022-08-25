// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Lottery.sol";
import "./RandomNumberGenerator.sol";

contract WelfareFactory is AccessControl {
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");
    mapping(uint256 => address) phases;
    uint64 subId;
    address vrfCoordinator;
    bytes32 keyHash;
    uint256 public phase;

    event NewLottery(address lottery, address gernerator);

    constructor(
        uint64 _subscriptionId,
        address _vrfCoordinator,
        bytes32 _keyHash
    ) {
        subId = _subscriptionId;
        vrfCoordinator = _vrfCoordinator;
        keyHash = _keyHash;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(FACTORY_ROLE, msg.sender);
    }

    function newLottery(uint8 _length)
        external
        onlyRole(FACTORY_ROLE)
        returns (address)
    {
        phase = phase + 1;
        Lottery lottery = new Lottery(phase);
        if (lottery.getLength() != _length) {
            lottery.setLength(_length);
        }
        phases[phase] = address(lottery);
        RandomNumberGenerator rg = new RandomNumberGenerator(
            subId,
            vrfCoordinator,
            keyHash
        );
        rg.transferOwnership(address(lottery));
        Lottery(lottery).setRandomNumberGenerator(address(rg));
        lottery.transferOwnership(msg.sender);
        emit NewLottery(address(lottery), address(rg));

        return address(lottery);
    }

    function newLotteryWithRNG(uint8 _length, address payable _lottery)
        external
        onlyRole(FACTORY_ROLE)
        returns (address)
    {
        phase = phase + 1;
        Lottery lottery = new Lottery(phase);
        if (lottery.getLength() != _length) {
            lottery.setLength(_length);
        }
        Lottery(_lottery).transferRNG(payable(lottery));
        address rng = Lottery(_lottery).randomNumberGenerator();
        lottery.setRandomNumberGenerator(rng);
        phases[phase] = address(lottery);
        lottery.transferOwnership(msg.sender);
        emit NewLottery(address(lottery), rng);

        return address(lottery);
    }

    function getLottery(uint256 _phase) external view returns (address) {
        return phases[_phase];
    }

    function transferRoleAdmin(address newDefaultAdmin)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(newDefaultAdmin != address(0), "Invalid address");
        _setupRole(DEFAULT_ADMIN_ROLE, newDefaultAdmin);
    }
}
