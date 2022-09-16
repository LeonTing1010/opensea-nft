// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../nft/Human.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";

contract HumanCrowdsale is AccessControl, PullPayment, Ownable {
    using SafeMath for uint256;
    bytes32 public constant CROWD_ROLE = keccak256("CROWD_ROLE");
    address public token;
    bool public allowed;
    uint256 public sLimit = 10; //single mint limit
    uint256 public mLimit = 3000; //total mining limit
    uint256 public salePrice = 0.35 ether;
    address public collector;
    uint256 public mAmount;
    address[] prerequisites;

    event PubSaleStarted(bool started);
    event AllowSaleStarted(bool started);
    event WhiteSaleStarted(bool started);
    event SalePriceChanged(uint256 price);
    event MLimitChanged(uint256 mLimit);
    event SLimitChanged(uint256 sLimit);
    event CollectorChanged(address collector);

    modifier onlyTokenOwner(address sender) {
        bool allIncluded = true;
        for (uint256 index = 0; index < prerequisites.length; index++) {
            uint256[] memory tokensIds = ERC721AQueryable(prerequisites[index])
                .tokensOfOwner(msg.sender);
            if (tokensIds.length <= 0) {
                allIncluded = false;
                break;
            }
        }
        require(allIncluded, "HumanCrowdsale:Does not meet the pre-requisites");
        _;
    }

    constructor(
        address _collector,
        address _nft,
        address[] memory _prerequisites
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CROWD_ROLE, msg.sender);
        collector = _collector;
        setNft(_nft);
        prerequisites = _prerequisites;
    }

    function mint(uint256 _amount) external payable onlyTokenOwner(msg.sender) {
        require(allowed, "HumanCrowdsale:Allow-List sale has not started");
        require(
            _amount <= sLimit,
            "HumanCrowdsale:Exceeded the single purchase limit"
        );
        require(
            msg.value == _amount.mul(salePrice),
            "HumanCrowdsale:Payment declined"
        );
        mAmount = mAmount.add(_amount);
        require(
            mAmount <= mLimit,
            "HumanCrowdsale:Exceeded the total amount of mining"
        );

        _asyncTransfer(collector, msg.value);
        Human(token).mint(msg.sender, _amount);
    }

    function setNft(address _nft) public onlyRole(CROWD_ROLE) {
        require(_nft != address(0), "HumanCrowdsale:Invalid address");
        token = _nft;
    }

    function setPrerequisites(address[] calldata _prerequisites)
        public
        onlyRole(CROWD_ROLE)
    {
        prerequisites = _prerequisites;
    }

    function setAllow(bool _allow) external onlyRole(CROWD_ROLE) {
        allowed = _allow;
        emit AllowSaleStarted(_allow);
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

    function totalMinted() external view returns (uint256) {
        return mAmount;
    }

    function setCollector(address _collector) external onlyOwner {
        require(_collector != address(0), "HumanCrowdsale:Invalid address");
        collector = _collector;
        emit CollectorChanged(collector);
    }

    function transferRoleAdmin(address newDefaultAdmin)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            newDefaultAdmin != address(0),
            "HumanCrowdsale:Invalid address"
        );
        _setupRole(DEFAULT_ADMIN_ROLE, newDefaultAdmin);
    }
}
