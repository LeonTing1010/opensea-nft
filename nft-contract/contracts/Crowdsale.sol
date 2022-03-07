// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./INFT.sol";

contract Crowdsale is PullPayment, Ownable, AccessControl, ReentrancyGuard {
    using SafeMath for uint256;
    // Create a new role identifier for the minter role
    bytes32 public constant MINER_ROLE = keccak256("MINER_ROLE");
    address public collector; //
    address public nft;
    bool public opening; // crowdsale opening status
    bool public closing; // crowdsale closing status
    uint256 public max;
    uint256 public limit;
    uint256 public publicSalePrice;
    uint256 public preSalePrice;

    mapping(address => uint256) quotas;
    mapping(address => uint256) sold;

    modifier onlyPositive(uint256 _number) {
        require(_number > 0, "Must be greater than 0");
        _;
    }

    constructor() {
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        collector = msg.sender;
        max = 10;
        limit = 5;
        preSalePrice = 0.5 ether;
        publicSalePrice = 0.5 ether;
        opening = false;
        closing = false;
    }

    function mint(uint256 _amount)
        external
        payable
        onlyPositive(_amount)
        nonReentrant
    {
        require(opening, "Sales time has not started");
        require(_amount <= limit, "More than one purchase");

        address miner = msg.sender;
        if (!closing) {
            require(msg.value == _amount.mul(preSalePrice), "Not Enough ETH");
            require(hasRole(MINER_ROLE, miner), "Address not whitelisted");
            sold[miner] = _amount.add(sold[miner]);
            (bool ok, ) = quotas[miner].trySub(sold[miner]);
            require(ok, "Exceeds Allocation");
        } else {
            require(
                msg.value == _amount.mul(publicSalePrice),
                "Not Enough ETH"
            );
            sold[miner] = _amount.add(sold[miner]);
            (bool ok, ) = max.trySub(sold[miner]);
            require(ok, "Exceeded maximum quantity limit");
        }
        _asyncTransfer(collector, msg.value);

        for (uint256 index = 0; index < _amount; index++) {
            INFT(nft).mintTo(miner);
        }
    }

    function grantLimits(address[] memory _accounts, uint256[] memory _limits)
        external
        onlyOwner
    {
        require(
            _accounts.length == _limits.length,
            "_accounts does not match _limits length"
        );
        for (uint256 index = 0; index < _accounts.length; index++) {
            address account = _accounts[index];
            require(_limits[index] <= max, "Exceeded maximum quantity limit");
            quotas[account] = _limits[index];
            super.grantRole(MINER_ROLE, account);
        }
    }

    function gift(address[] memory _accounts, uint256[] memory _amounts)
        external
        onlyOwner
    {
        require(
            _accounts.length == _amounts.length,
            "_accounts does not match _amounts length"
        );
        for (uint256 c = 0; c < _accounts.length; c++) {
            for (uint256 m = 0; m < _amounts[c]; m++) {
                INFT(nft).mintTo(_accounts[c]);
            }
        }
    }

    function allowance(address _account) public view returns (uint256) {
        uint256 result;
        if (closing) {
            (, result) = max.trySub(sold[_account]);
            return result;
        }
        (, result) = quotas[_account].trySub(sold[_account]);
        return result;
    }

    function soldBy(address _account) public view returns (uint256) {
        return sold[_account];
    }

    function setPreSalePrice(uint256 _price)
        external
        onlyOwner
        onlyPositive(_price)
    {
        preSalePrice = _price;
    }

    function setPublicSalePrice(uint256 _price)
        external
        onlyOwner
        onlyPositive(_price)
    {
        publicSalePrice = _price;
    }

    function setMaxAmount(uint32 _amount)
        external
        onlyOwner
        onlyPositive(_amount)
    {
        max = _amount;
    }

    function setMaxLimit(uint32 _limit)
        external
        onlyOwner
        onlyPositive(_limit)
    {
        limit = _limit;
    }

    function setNft(address _nft) external onlyOwner {
        require(_nft != address(0), "invalid address");
        nft = _nft;
    }

    function setOpening(bool _opening) external onlyOwner {
        opening = _opening;
    }

    function setClosing(bool _closing) external onlyOwner {
        closing = _closing;
    }

    function setCollector(address _collector) external onlyOwner {
        collector = _collector;
    }

    function remaining() external view returns (uint256) {
        return INFT(nft).remaining();
    }
}
