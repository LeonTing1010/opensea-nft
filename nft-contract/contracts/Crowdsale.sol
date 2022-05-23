// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./eip712/EIP712Sign.sol";
import "./nft/NFTERC721A.sol";

contract Crowdsale is EIP712Sign, PullPayment, AccessControl {
    using SafeMath for uint256;
    // Create a new role identifier for the minter role
    // bytes32 public constant MINER_ROLE = keccak256("MINER_ROLE");
    // bytes32 public constant GIFT_ROLE = keccak256("GIFT_ROLE");
    address public collector; //
    NFTERC721A public token;
    bool public opening; // crowdsale opening status
    bool public closing; // crowdsale closing status
    uint256 public max = 10;
    uint256 public limit = 5;
    uint256 public publicSalePrice = 0.09 ether;
    uint256 public preSalePrice = 0.07 ether;
    uint256 public giftLimit = 300;
    uint256 public TOTAL_SUPPLY = 777;

    mapping(address => uint256) quotas;
    mapping(address => uint256) sold;
    mapping(address => uint256) free;

    event PublicSalePriceChanged(uint256 price);
    event PreSalePriceChanged(uint256 price);
    event PreSaleStarted(bool opening);
    event PublicSaleStarted(bool closing);

    modifier onlyPositive(uint256 _number) {
        require(_number > 0, "Must be greater than 0");
        _;
    }

    constructor() {
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        collector = msg.sender;
    }

    function preMint(uint256 _amount, bytes calldata signature)
        external
        payable
        onlyPositive(_amount)
        requiresWhitelist(signature)
    {
        require(opening, "PreSales time has not started");
        require(_amount <= limit, "More than one purchase");
        require(msg.value == _amount.mul(preSalePrice), "Payment declined");
        require(token.current() <= TOTAL_SUPPLY, "Exceeded total supply");
        address miner = msg.sender;
        // require(hasRole(MINER_ROLE, miner), "Address not whitelisted");
        sold[miner] = _amount.add(sold[miner]);
        // (bool ok, ) = quotas[miner].trySub(sold[miner]);
        // require(ok, "Exceeds Allocation");
        _asyncTransfer(collector, msg.value);
        token.mint(miner, _amount);
    }

    function pubMint(uint256 _amount) external payable onlyPositive(_amount) {
        require(closing, "PubSales time has not started");
        require(_amount <= limit, "More than one purchase");
        require(msg.value == _amount.mul(publicSalePrice), "Payment declined");
        require(token.current() <= TOTAL_SUPPLY, "Exceeded total supply");
        address miner = msg.sender;
        sold[miner] = _amount.add(sold[miner]);
        // (bool ok, ) = max.trySub(sold[miner]);
        // require(ok, "Exceeded maximum quantity limit");
        _asyncTransfer(collector, msg.value);
        token.mint(miner, _amount);
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
            //super.grantRole(MINER_ROLE, account);
        }
    }

    function gift(uint256 _amount, bytes calldata signature)
        external
        requiresGift(signature)
    {
        require(!opening, "Gift time is over");
        require(_amount <= limit, "More than one purchase");
        address miner = msg.sender;
        free[miner] = _amount.add(free[miner]);
        require(free[miner] <= max, "Exceeded maximum quantity limit");
        token.mint(miner, _amount);
    }

    function freeMinted(address _account) public view returns (uint256) {
        return free[_account];
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
        emit PreSalePriceChanged(preSalePrice);
    }

    function setPublicSalePrice(uint256 _price)
        external
        onlyOwner
        onlyPositive(_price)
    {
        publicSalePrice = _price;
        emit PublicSalePriceChanged(publicSalePrice);
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
        token = NFTERC721A(_nft);
    }

    function setOpening(bool _opening) external onlyOwner {
        opening = _opening;
        emit PreSaleStarted(opening);
    }

    function setClosing(bool _closing) external onlyOwner {
        closing = _closing;
        emit PublicSaleStarted(closing);
    }

    function setCollector(address _collector) external onlyOwner {
        require(_collector != address(0), "invalid address");
        collector = _collector;
    }

    function remaining() external view returns (uint256) {
        return TOTAL_SUPPLY - token.current();
    }

    function transferRoleAdmin(address newDefaultAdmin)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, newDefaultAdmin);
    }
}
