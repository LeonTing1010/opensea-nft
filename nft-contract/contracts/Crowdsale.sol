// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./eip712/WhitelistSign.sol";
import "./eip712/GiftlistSign.sol";
import "./nft/NFTERC721A.sol";

contract Crowdsale is
    EIP712Sign,
    WhitelistSign,
    GiftlistSign,
    PullPayment,
    AccessControl
{
    using SafeMath for uint256;
    // Create a new role identifier for the crowdsale role
    bytes32 public constant CROWD_ROLE = keccak256("CROWD_ROLE");
    address public collector; //
    NFTERC721A public token;
    bool public opening; // crowdsale opening status
    bool public closing; // crowdsale closing status
    uint256 public max = 10; //Maximum purchase limit
    uint256 public limit = 5; // single purchase limit
    uint256 public publicSalePrice = 0.09 ether;
    uint256 public preSalePrice = 0.07 ether;
    uint256 public constant GIFT_LIMIT = 300;
    uint256 public totalGift;
    uint256 public totalGrant;
    uint256 public constant TOTAL_SUPPLY = 10800;

    mapping(address => uint256) quotas;
    mapping(address => uint256) sold;
    mapping(address => uint256) free;

    event PublicSalePriceChanged(uint256 price);
    event PreSalePriceChanged(uint256 price);
    event PreSaleStarted(bool opening);
    event PublicSaleStarted(bool closing);
    event SettedMaxAmount(uint256 max);
    event SettedLimit(uint256 limit);

    modifier onlyPositive(uint256 _number) {
        require(_number > 0, "Must be greater than 0");
        _;
    }

    constructor() EIP712Sign("Crowdsale") {
        require(
            GIFT_LIMIT < TOTAL_SUPPLY,
            "GIFT_LIMIT greater than TOTAL_SUPPLY"
        );
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CROWD_ROLE, msg.sender);
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
        address miner = msg.sender;
        sold[miner] = _amount.add(sold[miner]);

        _asyncTransfer(collector, msg.value);
        token.mint(miner, _amount);
    }

    function pubMint(uint256 _amount) external payable onlyPositive(_amount) {
        require(closing, "PubSales time has not started");
        require(_amount <= limit, "More than one purchase");
        require(msg.value == _amount.mul(publicSalePrice), "Payment declined");
        address miner = msg.sender;
        sold[miner] = _amount.add(sold[miner]);

        _asyncTransfer(collector, msg.value);
        token.mint(miner, _amount);
    }

    function grantLimits(address[] memory _accounts, uint256[] memory _limits)
        external
        onlyRole(CROWD_ROLE)
    {
        require(
            _accounts.length == _limits.length,
            "_accounts does not match _limits length"
        );

        for (uint256 index = 0; index < _accounts.length; index++) {
            address account = _accounts[index];
            require(_limits[index] <= max, "Exceeded maximum quantity limit");
            quotas[account] = _limits[index];

            totalGrant = totalGrant + _limits[index];
            require(totalGrant < TOTAL_SUPPLY, "Invaild grant limit");
        }
    }

    function gift(uint256 _amount, bytes calldata signature)
        external
        requiresGiftlist(signature)
    {
        require(!opening, "Gift time is over");
        require(_amount <= limit, "More than one purchase");
        address miner = msg.sender;
        free[miner] = _amount.add(free[miner]);
        require(free[miner] <= max, "Exceeded maximum quantity limit");
        totalGift = totalGift + _amount;
        require(totalGift <= GIFT_LIMIT, "Exceeded the maximum gifts limit");
        token.mint(miner, _amount);
    }

    function freeMinted(address _account) external view returns (uint256) {
        return free[_account];
    }

    function allowance(address _account) external view returns (uint256) {
        uint256 result;
        if (closing) {
            (, result) = max.trySub(sold[_account]);
            return result;
        }
        (, result) = quotas[_account].trySub(sold[_account]);
        return result;
    }

    function soldBy(address _account) external view returns (uint256) {
        return sold[_account];
    }

    function setPreSalePrice(uint256 _price)
        external
        onlyRole(CROWD_ROLE)
        onlyPositive(_price)
    {
        preSalePrice = _price;
        emit PreSalePriceChanged(preSalePrice);
    }

    function setPublicSalePrice(uint256 _price)
        external
        onlyRole(CROWD_ROLE)
        onlyPositive(_price)
    {
        publicSalePrice = _price;
        emit PublicSalePriceChanged(publicSalePrice);
    }

    function setMaxAmount(uint32 _amount)
        external
        onlyRole(CROWD_ROLE)
        onlyPositive(_amount)
    {
        require(_amount < TOTAL_SUPPLY, "Invalid amount");
        max = _amount;
        emit SettedMaxAmount(max);
    }

    function setLimit(uint32 _limit)
        external
        onlyRole(CROWD_ROLE)
        onlyPositive(_limit)
    {
        require(_limit < max, "Invalid limit");
        limit = _limit;
        emit SettedLimit(limit);
    }

    function setNft(address _nft) external onlyRole(CROWD_ROLE) {
        require(_nft != address(0), "Invalid address");
        token = NFTERC721A(_nft);
    }

    function setOpening(bool _opening) external onlyRole(CROWD_ROLE) {
        opening = _opening;
        if (_opening == true) {
            closing = false;
        }
        emit PreSaleStarted(opening);
    }

    function setClosing(bool _closing) external onlyRole(CROWD_ROLE) {
        closing = _closing;
        if (closing == true) {
            opening = false;
        }
        emit PublicSaleStarted(closing);
    }

    function setCollector(address _collector) external onlyOwner {
        require(_collector != address(0), "Invalid address");
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
