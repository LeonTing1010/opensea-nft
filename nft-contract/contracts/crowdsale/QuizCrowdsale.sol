// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../nft/NFTERC721A.sol";
import "../nft/IAfterTokenTransfer.sol";
import "../lottery/Lottery.sol";

contract QuizCrowdsale is
    AccessControl,
    PullPayment,
    Ownable,
    IAfterTokenTransfer
{
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    bytes32 public constant CROWD_ROLE = keccak256("CROWD_ROLE");
    uint8 public quiz;
    address public token;
    address payable public lottery;
    bool public opening; // airdrop opening status
    uint256 public sLimit = 10; //single mint limit
    uint256 public mLimit = 1000; //total mining limit
    uint256 public salePrice = 0.01 ether;
    address public collector;
    uint256 public mAmount;
    mapping(address => Quiz[]) quizzes;
    EnumerableSet.AddressSet private stars;

    struct Quiz {
        uint256 start;
        uint256 amount;
        uint8 option;
    }

    event PubSaleStarted(bool opening);
    event SalePriceChanged(uint256 price);
    event MLimitChanged(uint256 mLimit);
    event SLimitChanged(uint256 sLimit);
    event CollectorChanged(address collector);
    event QuizMinted(
        address indexed to,
        uint256 startTokenId,
        uint256 quantity,
        uint8 quiz
    );

    modifier onlyToken() {
        require(token == msg.sender, "QuizCrowdsale: caller is not the token");
        _;
    }

    constructor(address _collector, address _nft) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CROWD_ROLE, msg.sender);
        collector = _collector;
        token = _nft;
    }

    function mint(uint256 _amount, uint8 _quiz) external payable {
        require(opening, "QuizCrowdsale: Public sale has ended");
        require(
            _amount <= sLimit,
            "QuizCrowdsale: Exceeded the single purchase limit"
        );
        require(
            msg.value == _amount.mul(salePrice),
            "QuizCrowdsale: Payment declined"
        );
        mAmount = mAmount.add(_amount);
        require(
            mAmount <= mLimit,
            "QuizCrowdsale: Exceeded the total amount of mining"
        );
        _asyncTransfer(collector, msg.value);
        if (_quiz > quiz) {
            quiz = _quiz;
        }
        address star = msg.sender;
        uint256 startTokenId = NFTERC721A(token).nextTokenId();
        quizzes[star].push(Quiz(startTokenId, _amount, _quiz));
        stars.add(star);
        NFTERC721A(token).mint(star, _amount);
    }

    function setNft(address _nft) public onlyRole(CROWD_ROLE) {
        require(_nft != address(0), "QuizCrowdsale: Invalid address");
        token = _nft;
        NFTERC721A(token).setAfterTransfer(address(this));
        // token.setApprovalForAll(msg.sender, true);
    }

    function setLottery(address payable _lottery) public onlyRole(CROWD_ROLE) {
        require(_lottery != address(0), "QuizCrowdsale: Invalid address");
        require(!opening, "QuizCrowdsale: The sale is not over yet");
        lottery = _lottery;
        for (uint256 si = 0; si < stars.length(); si++) {
            address star = stars.at(si);
            delete quizzes[star];
            stars.remove(star);
        }
    }

    function setOpening(bool _opening) external onlyRole(CROWD_ROLE) {
        require(opening != _opening);
        opening = _opening;
        emit PubSaleStarted(opening);
    }

    function setSalePrice(uint256 _price) external onlyRole(CROWD_ROLE) {
        require(_price > 0);
        salePrice = _price;
        emit SalePriceChanged(salePrice);
    }

    function setMLimit(uint256 _mLimit) external onlyRole(CROWD_ROLE) {
        require(_mLimit > 0);
        mLimit = _mLimit;
        emit MLimitChanged(mLimit);
    }

    function setSLimit(uint256 _sLimit) external onlyRole(CROWD_ROLE) {
        require(_sLimit > 0);
        sLimit = _sLimit;
        emit SLimitChanged(sLimit);
    }

    function current() external view returns (uint256) {
        return NFTERC721A(token).current();
    }

    function totalMinted() external view returns (uint256) {
        return mAmount;
    }

    function setCollector(address _collector) external onlyOwner {
        require(_collector != address(0), "QuizCrowdsale: Invalid address");
        collector = _collector;
        emit CollectorChanged(collector);
    }

    function transferRoleAdmin(address newDefaultAdmin)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            newDefaultAdmin != address(0),
            "QuizCrowdsale: Invalid address"
        );
        _setupRole(DEFAULT_ADMIN_ROLE, newDefaultAdmin);
    }

    function getQuizes(address star) external view returns (Quiz[] memory) {
        return quizzes[star];
    }

    function gift(uint256[] memory _lotteries) external onlyRole(CROWD_ROLE) {
        require(!opening, "QuizCrowdsale: The sale is not over yet");
        require(
            _lotteries.length == quiz + 1,
            "QuizCrowdsale: The length is not equal to the number of quiz options"
        );
        for (uint256 si = 0; si < stars.length(); si++) {
            address star = stars.at(si);
            Quiz[] memory qs = quizzes[star];
            for (uint256 index = 0; index < qs.length; index++) {
                Quiz memory _quiz = qs[index];
                uint256 quantity = _quiz.amount.mul(_lotteries[_quiz.option]);
                if (quantity > 0) {
                    Lottery(lottery).twist(star, quantity);
                }
            }
        }
    }

    function onTokenMinted(
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) external onlyToken {
        Quiz[] memory qs = quizzes[to];
        for (uint256 qi = 0; qi < qs.length; qi++) {
            if (qs[qi].start == startTokenId) {
                emit QuizMinted(to, startTokenId, quantity, qs[qi].option);
            }
        }
    }
}
