// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Crowdsale is PullPayment, Ownable, AccessControl {
    using SafeMath for uint256;
    // Create a new role identifier for the minter role
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant TOTAL_SUPPLY = 10_000;
    uint256 public constant MINT_PRICE = 0.01 ether;

    address public nftAddress;
    uint256 public price;

    uint256 public openingTime; // crowdsale opening time
    uint256 public closingTime; // crowdsale closing time

    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;

    mapping(address => uint256) quotas;
    uint256 public total = 0;

    /**
     * @dev Reverts if not in crowdsale time range.
     */
    modifier onlyWhileOpen() {
        // solium-disable-next-line security/no-block-members
        require(
            block.timestamp >= openingTime && block.timestamp <= closingTime
        );
        _;
    }

    modifier onlyPositive(uint256 _price) {
        if (_price > 0) {
            _;
        }
    }

    constructor() {
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        price = MINT_PRICE;
    }

    function mint()
        public
        payable
        onlyRole(MINTER_ROLE)
        onlyWhileOpen
        returns (uint256)
    {
        currentTokenId.increment();
        uint256 tokenId = currentTokenId.current();
        require(tokenId <= TOTAL_SUPPLY, "Max supply reached");
        require(
            msg.value >= price,
            "Transaction value did not greater than the mint price"
        );
        uint256 left = quotas[msg.sender];
        require(left > 0, "Over the limit");
        (bool success, ) = nftAddress.call(
            abi.encodeWithSignature("mintTo(address)", msg.sender)
        );
        require(success, "Mining failed");
        quotas[msg.sender] = left.sub(1);
        _asyncTransfer(owner(), msg.value);
        return tokenId;
    }

    function setLimit(address _account, uint _limit)
        public
        onlyOwner
        onlyPositive(_limit)
    {
        total = total.add(_limit);
        require(total <= TOTAL_SUPPLY, "Max supply reached");
        quotas[_account] = _limit;
        super.grantRole(MINTER_ROLE, _account);
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

    function setNftAddress(address _nftAddress) external {
        nftAddress = _nftAddress;
    }

    function setOpeningTime(uint256 _openingTime) external {
        openingTime = _openingTime;
    }

    function setClosingTime(uint256 _closingTime) external {
        closingTime = _closingTime;
    }
}
