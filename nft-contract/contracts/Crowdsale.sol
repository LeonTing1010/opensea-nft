// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./nft/NFTERC721A.sol";

contract Crowdsale is AccessControl, PullPayment, Ownable {
    using SafeMath for uint256;
    bytes32 public constant CROWD_ROLE = keccak256("CROWD_ROLE");
    NFTERC721A public token;
    bool public opening; // airdrop opening status
    uint256 public sLimit = 10; //single mint limit
    uint256 public mLimit = 1000; //total mining limit
    uint256 public salePrice = 0.15 ether;
    uint256 public tSupply = 2000;
    address public collector;
    uint256 public mAmount;
    uint256 public totalSupply;

    event AirdropStarted(bool opening);
    event SalePriceChanged(uint256 price);
    event MLimitChanged(uint256 mLimit);
    event SLimitChanged(uint256 sLimit);
    event TSupplyChanged(uint256 tSupply);
    event CollectorChanged(address collector);

    constructor(address _collector, address _nft) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CROWD_ROLE, msg.sender);
        collector = _collector;
        token = NFTERC721A(_nft);
        // token.setApprovalForAll(msg.sender, true);
    }

    function mint(uint256 _amount) external payable {
        require(!opening, "Public sale has ended");
        require(_amount <= sLimit, "Exceeded the single purchase limit");
        require(msg.value == _amount.mul(salePrice), "Payment declined");
        mAmount = mAmount.add(_amount);
        require(mAmount <= mLimit, "Exceeded the total amount of mining");
        totalSupply = totalSupply.add(_amount);
        require(totalSupply <= tSupply, "Exceeded total supply");
        _asyncTransfer(collector, msg.value);
        token.mint(msg.sender, _amount);
    }

    function setNft(address _nft) external onlyRole(CROWD_ROLE) {
        require(_nft != address(0), "Invalid address");
        token = NFTERC721A(_nft);
    }

    function setOpening(bool _opening) external onlyRole(CROWD_ROLE) {
        opening = _opening;
        emit AirdropStarted(opening);
    }

    function setSalePrice(uint256 _price) external onlyRole(CROWD_ROLE) {
        salePrice = _price;
        emit SalePriceChanged(salePrice);
    }

    function setMLimit(uint256 _mLimit) external onlyRole(CROWD_ROLE) {
        mLimit = _mLimit;
        emit MLimitChanged(mLimit);
    }

    function setSLimit(uint256 _sLimit) external onlyRole(CROWD_ROLE) {
        sLimit = _sLimit;
        emit SLimitChanged(sLimit);
    }

    function setTSupply(uint256 _tSupply) external onlyRole(CROWD_ROLE) {
        tSupply = _tSupply;
        emit TSupplyChanged(tSupply);
    }

    function current() external view returns (uint256) {
        return token.current();
    }

    function totalMinted() external view returns (uint256) {
        return mAmount;
    }

    function gift(address[] calldata _accounts, uint256[] calldata _quantity)
        external
        onlyRole(CROWD_ROLE)
    {
        require(opening, "Airdrop has not started");
        require(
            _accounts.length == _quantity.length,
            "The two arrays are not equal in length"
        );
        uint256 amount;
        for (uint256 index = 0; index < _quantity.length; index++) {
            amount = amount.add(_quantity[index]);
        }
        totalSupply = totalSupply.add(amount);
        require(totalSupply <= tSupply, "Exceeded total supply");
        for (uint256 index = 0; index < _accounts.length; index++) {
            token.mint(_accounts[index], _quantity[index]);
        }
    }

    function transferById(
        uint256 startTokenId,
        address[] memory _accounts,
        uint256[] memory _quantity
    ) external onlyRole(CROWD_ROLE) {
        require(opening, "Airdrop has not started");
        require(
            _accounts.length == _quantity.length,
            "The two arrays are not equal in length"
        );
        uint256 balance = token.balanceOf(msg.sender);
        require(balance > 0, "Insufficient balance");
        uint256 tokenId = startTokenId;
        for (uint256 ia = 0; ia < _accounts.length; ia++) {
            for (uint256 iq = 0; iq < _quantity[ia]; iq++) {
                token.transferFrom(msg.sender, _accounts[ia], tokenId);
                tokenId = tokenId + 1;
            }
        }
    }

    function setCollector(address _collector) external onlyOwner {
        require(_collector != address(0), "Invalid address");
        collector = _collector;
        emit CollectorChanged(collector);
    }

    function transferRoleAdmin(address newDefaultAdmin)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(newDefaultAdmin != address(0), "Invalid address");
        _setupRole(DEFAULT_ADMIN_ROLE, newDefaultAdmin);
    }
}
