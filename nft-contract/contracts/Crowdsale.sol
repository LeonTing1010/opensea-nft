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
    uint256 public price;

    mapping(address => uint256) quotas;

    modifier onlyPositive(uint256 _price) {
        if (_price > 0) {
            _;
        }
    }

    constructor() {
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        collector = msg.sender;
        price = 0.01 ether;
    }

    function mint(uint256 _amount) public payable onlyPositive(_amount) {
        require(block.timestamp >= openingTime, "Sales time has not started");
        address miner = msg.sender;
        if (block.timestamp <= closingTime) {
            require(
                hasRole(MINER_ROLE, miner),
                "Please join the whitelist first"
            );
        }
        require(
            msg.value == price,
            "Transaction value is not equal to mint price"
        );
        uint256 left = quotas[miner];
        require(left >= _amount, "Over the limit");
        quotas[miner] = left.sub(_amount);
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
            quotas[account] = _limits[index];
            super.grantRole(MINER_ROLE, account);
        }
    }

    function limit(address _account) public view returns (uint256) {
        return quotas[_account];
    }

    function setPrice(uint256 _price)
        public
        virtual
        onlyOwner
        onlyPositive(_price)
    {
        price = _price;
    }

    /// @dev Overridden in order to make it an onlyOwner function
    function withdrawPayments(address payable _payee)
        public
        virtual
        override
        onlyOwner
    {
        super.withdrawPayments(_payee);
    }

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
