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
    uint8 len;
    address rg;

    event NewLottery(address lottery);
    event NewGenerator(address lottery, address gernerator);

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
        len = 7;
    }

    function _newLottery(uint8 _length) private returns (address) {
        phase = phase + 1;
        Lottery lottery = new Lottery(phase);
        if (lottery.getLength() != _length) {
            lottery.setLength(_length);
        }
        emit NewLottery(address(lottery));
        phases[phase] = address(lottery);

        return address(lottery);
    }

    function newLottery(uint8 _length)
        external
        onlyRole(FACTORY_ROLE)
        returns (address)
    {
        address payable lottery = payable(_newLottery(_length));
        RandomNumberGenerator _rg = new RandomNumberGenerator(
            subId,
            vrfCoordinator,
            keyHash
        );
        _rg.addWhitelist(lottery);
        Lottery(lottery).setRandomNumberGenerator(address(_rg));
        Lottery(lottery).transferOwnership(msg.sender);
        emit NewGenerator(lottery, address(_rg));
        return lottery;
    }

    function newLottery7() external onlyRole(FACTORY_ROLE) returns (address) {
        address payable lottery = payable(_newLottery(len));
        if (rg == address(0)) {
            RandomNumberGenerator _rg = new RandomNumberGenerator(
                subId,
                vrfCoordinator,
                keyHash
            );
            rg = address(_rg);
        }
        RandomNumberGenerator(rg).addWhitelist(lottery);
        Lottery(lottery).setRandomNumberGenerator(rg);
        Lottery(lottery).transferOwnership(msg.sender);
        emit NewGenerator(lottery, rg);
        return lottery;
    }

    function setLen(uint8 _length) external onlyRole(FACTORY_ROLE) {
        require(
            _length >= 1 && _length <= 84,
            "WelfareFactory: Invalid length"
        );
        len = _length;
    }

    function getLottery(uint256 _phase) external view returns (address) {
        return phases[_phase];
    }

    function current() external view returns (address lottery) {
        lottery = phases[phase];
        if (lottery != address(0)) {
            if (uint8(Lottery(payable(lottery)).state()) > 0) {
                lottery = address(0);
            }
        }
    }

    function transferRoleAdmin(address newDefaultAdmin)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            newDefaultAdmin != address(0),
            "WelfareFactory: Invalid address"
        );
        _setupRole(DEFAULT_ADMIN_ROLE, newDefaultAdmin);
    }
}
