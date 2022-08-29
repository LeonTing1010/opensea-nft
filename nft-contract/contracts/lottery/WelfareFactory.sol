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

    event NewLottery(uint256 phase, address lottery, address gernerator);

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

    function newLottery(uint8 _prizes)
        external
        onlyRole(FACTORY_ROLE)
        returns (address)
    {
        phase = phase + 1;
        Lottery lottery = new Lottery(phase, _prizes);
        phases[phase] = address(lottery);
        RandomNumberGenerator rg = new RandomNumberGenerator(
            subId,
            vrfCoordinator,
            keyHash
        );
        rg.transferOwnership(address(lottery));
        Lottery(lottery).setRandomNumberGenerator(address(rg));
        lottery.transferOwnership(msg.sender);
        emit NewLottery(phase, address(lottery), address(rg));

        return address(lottery);
    }

    function newLotteryWithRNG(uint8 _prizes, address payable _lottery)
        external
        onlyRole(FACTORY_ROLE)
        returns (address)
    {
        phase = phase + 1;
        Lottery lottery = new Lottery(phase, _prizes);
        Lottery(_lottery).transferRNG(payable(lottery));
        phases[phase] = address(lottery);
        lottery.transferOwnership(msg.sender);
        emit NewLottery(phase, address(lottery), Lottery(_lottery).rng());

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
