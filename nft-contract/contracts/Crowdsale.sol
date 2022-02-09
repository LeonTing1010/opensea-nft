// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./INFT.sol";

contract Crowdsale is PullPayment, Ownable, AccessControl {
    using SafeMath for uint256;
    // Create a new role identifier for the minter role
    bytes32 public constant MINER_ROLE = keccak256("MINER_ROLE");
    address public collector; //
    address public nft;
    uint32 public openingTime; // crowdsale opening time
    uint32 public closingTime; // crowdsale closing time
    uint256 public max;
    uint256 public price;

    mapping(address => uint256) quotas;
    mapping(address => uint256) sold;

    modifier onlyPositive(uint256 _number) {
        require(_number >0, "Must be greater than 0");
        _;
    }

    constructor() {
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        collector = msg.sender;
        max = 5;
        price = 0.01 ether;
    }

    function mint(uint256 _amount) public payable onlyPositive(_amount) {
        require(block.timestamp >= openingTime, "Sales time has not started");
        require(
            msg.value == _amount.mul(price),
            "Transaction value is not equal to price*_amount"
        );
        address miner = msg.sender;
        if (block.timestamp <= closingTime) {
            require(
                hasRole(MINER_ROLE, miner),
                "Please join the whitelist first"
            );
            sold[miner] = _amount.add(sold[miner]);
            (bool ok, ) = quotas[miner].trySub(sold[miner]);
            require(ok, "Over the limit");
        } else {
            sold[miner] = _amount.add(sold[miner]);
            (bool ok, ) = max.trySub(sold[miner]);
            require(ok, "Exceeded maximum quantity limit");
        }
        _asyncTransfer(collector, msg.value);

        for (uint256 index = 0; index < _amount; index++) {
            INFT(nft).mintTo(miner);
        }
    }

    function setLimit(address _account, uint256 _limit)
        public
        onlyOwner
        onlyPositive(_limit)
    {
        require(_limit <= max, "Exceeded maximum quantity limit");
        quotas[_account] = _limit;
        super.grantRole(MINER_ROLE, _account);
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

    function limit(address _account) public view returns (uint256) {
        uint256 result;
        if (block.timestamp > closingTime) {
            (, result) = max.trySub(sold[_account]);
            return result;
        }
        (, result) = quotas[_account].trySub(sold[_account]);
        return result;
    }

    function soldBy(address _account) public view returns (uint256) {
        return sold[_account];
    }

    function setPrice(uint256 _price) external onlyOwner onlyPositive(_price) {
        price = _price;
    }

    function setMaxAmount(uint32 _amount)
        external
        onlyOwner
        onlyPositive(_amount)
    {
        max = _amount;
    }

    // /// @dev Overridden in order to make it an onlyOwner function
    // function withdrawPayments(address payable _payee)
    //     public
    //     virtual
    //     override
    // {
    //     super.withdrawPayments(_payee);
    // }

    function setNft(address _nft) external onlyOwner {
        nft = _nft;
    }

    function setOpeningTime(uint32 _openingTime) external onlyOwner {
        openingTime = _openingTime;
    }

    function setClosingTime(uint32 _closingTime) external onlyOwner {
        closingTime = _closingTime;
    }

    function setCollector(address _collector) external onlyOwner {
        collector = _collector;
    }
}
