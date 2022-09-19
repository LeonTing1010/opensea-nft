// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../nft/Human.sol";
import "../eip712/Signer.sol";
import "../nft/Teaser.sol";

contract HumanCrowdsale is AccessControl, PullPayment, Ownable, Signer {
    using SafeMath for uint256;
    bytes32 public constant CROWD_ROLE = keccak256("CROWD_ROLE");
    address public token;
    address public teaser;
    bool public allowed;
    bool public white;
    bool public pub;
    uint256 public sLimit = 10; //single mint limit
    uint256 public mLimit = 4000; //total mining limit
    uint256 public salePrice = 0.25 ether;
    address public collector;
    uint256 public mAmount;

    event PubSaleStarted(bool started);
    event AllowSaleStarted(bool started);
    event WhiteSaleStarted(bool started);
    event SalePriceChanged(uint256 price);
    event MLimitChanged(uint256 mLimit);
    event SLimitChanged(uint256 sLimit);
    event CollectorChanged(address collector);

    constructor(
        address _collector,
        address _nft,
        address _teaser
    ) Signer(Human(_nft).symbol()) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CROWD_ROLE, msg.sender);
        collector = _collector;
        setNft(_nft);
        setTeaser(_teaser);
    }

    function allowMint(uint256 _amount, bytes calldata _signature)
        external
        payable
        requiresSignature(_signature)
    {
        require(allowed, "HUMANCROWDSALE:Allow-List sale has not started");
        require(
            _amount <= sLimit,
            "HUMANCROWDSALE:Exceeded the single purchase limit"
        );
        require(
            msg.value == _amount.mul(salePrice),
            "HUMANCROWDSALE:Payment declined"
        );
        mAmount = mAmount.add(_amount);
        require(
            mAmount <= mLimit,
            "HUMANCROWDSALE:Exceeded the total amount of mining"
        );
        _asyncTransfer(collector, msg.value);
        Human(token).mint(msg.sender, _amount);
    }

    function whiteMint(uint256 _amount) external payable {
        require(white, "HUMANCROWDSALE:White-List sale has not started");
        require(
            _amount <= sLimit,
            "HUMANCROWDSALE:Exceeded the single purchase limit"
        );
        require(
            msg.value == _amount.mul(salePrice),
            "HUMANCROWDSALE:Payment declined"
        );
        mAmount = mAmount.add(_amount);
        require(
            mAmount <= mLimit,
            "HUMANCROWDSALE:Exceeded the total amount of mining"
        );
        uint256[] memory tokensIds = Teaser(teaser).tokensOfOwner(msg.sender);
        require(
            tokensIds.length > 0,
            "HUMANCROWDSALE:Not eligible for purchase"
        );
        _asyncTransfer(collector, msg.value);
        Human(token).mint(msg.sender, _amount);
    }

    function pubMint(uint256 _amount) external payable {
        require(pub, "HUMANCROWDSALE:Public sale has not started");
        require(
            _amount <= sLimit,
            "HUMANCROWDSALE:Exceeded the single purchase limit"
        );
        require(
            msg.value == _amount.mul(salePrice),
            "HUMANCROWDSALE:Payment declined"
        );
        mAmount = mAmount.add(_amount);
        require(
            mAmount <= mLimit,
            "HUMANCROWDSALE:Exceeded the total amount of mining"
        );
        _asyncTransfer(collector, msg.value);
        Human(token).mint(msg.sender, _amount);
    }

    function setNft(address _nft) public onlyRole(CROWD_ROLE) {
        require(_nft != address(0), "HUMANCROWDSALE:Invalid address");
        token = _nft;
    }

    function setTeaser(address _teaser) public onlyRole(CROWD_ROLE) {
        require(_teaser != address(0), "HUMANCROWDSALE:Invalid address");
        teaser = _teaser;
    }

    function setAllow(bool _allow) external onlyRole(CROWD_ROLE) {
        allowed = _allow;
        emit AllowSaleStarted(_allow);
    }

    function setWhite(bool _white) external onlyRole(CROWD_ROLE) {
        white = _white;
        emit WhiteSaleStarted(_white);
    }

    function setPub(bool _pub) external onlyRole(CROWD_ROLE) {
        pub = _pub;
        emit PubSaleStarted(_pub);
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
        require(_collector != address(0), "HUMANCROWDSALE:Invalid address");
        collector = _collector;
        emit CollectorChanged(collector);
    }

    function transferRoleAdmin(address newDefaultAdmin)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            newDefaultAdmin != address(0),
            "HUMANCROWDSALE:Invalid address"
        );
        _setupRole(DEFAULT_ADMIN_ROLE, newDefaultAdmin);
    }
}
