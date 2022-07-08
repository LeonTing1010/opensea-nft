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
    uint256 public constant TotalSupply = 6888;
    uint256 public constant SLimit = 10; //single mint limit
    uint256 public constant MLimit = 1000; //mining mint limit
    uint256 public salePrice = 0.15 ether;
    address public collector;
    uint256 public mAmount;

    event AirdropStarted(bool opening);
    event SalePriceChanged(uint256 price);

    constructor(address _collector) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CROWD_ROLE, msg.sender);
        collector = _collector;
    }

    function mint(uint256 _amount) external payable {
        require(!opening, "Public sale has ended");
        require(_amount <= SLimit, "Exceeded the single purchase limit");
        require(msg.value == _amount.mul(salePrice), "Payment declined");
        mAmount = mAmount.add(_amount);
        require(mAmount <= MLimit, "Exceeded the total amount of mining");

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

    function current() external view returns (uint256) {
        return token.current();
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
        for (uint256 index = 0; index < _accounts.length; index++) {
            token.mint(_accounts[index], _quantity[index]);
        }
    }

    function setCollector(address _collector) external onlyOwner {
        require(_collector != address(0), "Invalid address");
        collector = _collector;
    }

    function transferRoleAdmin(address newDefaultAdmin)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(newDefaultAdmin != address(0), "Invalid address");
        _setupRole(DEFAULT_ADMIN_ROLE, newDefaultAdmin);
    }
}
