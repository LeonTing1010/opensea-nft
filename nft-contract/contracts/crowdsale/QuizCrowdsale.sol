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
import "../lottery/WelfareFactory.sol";

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
    address public welfareFactory;
    bool public opening; // airdrop opening status
    uint256 public sLimit = 10; //single mint limit
    uint256 public mLimit = 1000; //total mining limit
    uint256 public salePrice = 0.01 ether;
    address public collector;
    uint256 public mAmount;
    mapping(address => Quiz[]) quizzes;
    EnumerableSet.AddressSet private stars;
    mapping(address => uint256) lotteries;
    uint256 public numberOfLotteries;
    CrowdsaleState public state;

    enum CrowdsaleState {
        Start,
        Mint,
        Gift,
        Finish
    }

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
    event CrowdsaleStateChanged(CrowdsaleState _state);
    //modifiers
    modifier isState(CrowdsaleState _state) {
        require(state == _state, "QuizCrowdsale: Wrong state for this action");
        _;
    }
    modifier onlyToken() {
        require(token == msg.sender, "QuizCrowdsale: caller is not the token");
        _;
    }

    constructor(address _collector, address _nft) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CROWD_ROLE, msg.sender);
        collector = _collector;
        token = _nft;
        _changeState(CrowdsaleState.Start);
    }

    function mint(uint256 _amount, uint8 _quiz)
        external
        payable
        isState(CrowdsaleState.Mint)
    {
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

    function setNft(address _nft)
        public
        onlyRole(CROWD_ROLE)
        isState(CrowdsaleState.Start)
    {
        require(_nft != address(0), "QuizCrowdsale: Invalid address");
        token = _nft;
        NFTERC721A(token).setAfterTransfer(address(this));
        // token.setApprovalForAll(msg.sender, true);
    }

    function setLottery(address _welfareFactory)
        public
        onlyRole(CROWD_ROLE)
        isState(CrowdsaleState.Start)
    {
        require(
            _welfareFactory != address(0),
            "QuizCrowdsale: Invalid address"
        );
        require(!opening, "QuizCrowdsale: The sale is not over yet");
        welfareFactory = _welfareFactory;
        for (uint256 si = 0; si < stars.length(); si++) {
            address star = stars.at(si);
            delete quizzes[star];
            stars.remove(star);
        }
    }

    function setOpening(bool _opening) external onlyRole(CROWD_ROLE) {
        require(opening != _opening);
        opening = _opening;
        if (opening) {
            _changeState(CrowdsaleState.Mint);
        } else {
            _changeState(CrowdsaleState.Gift);
        }
        emit PubSaleStarted(opening);
    }

    function setSalePrice(uint256 _price)
        external
        onlyRole(CROWD_ROLE)
        isState(CrowdsaleState.Start)
    {
        require(_price > 0);
        salePrice = _price;
        emit SalePriceChanged(salePrice);
    }

    function setMLimit(uint256 _mLimit)
        external
        onlyRole(CROWD_ROLE)
        isState(CrowdsaleState.Start)
    {
        require(_mLimit > 0);
        mLimit = _mLimit;
        emit MLimitChanged(mLimit);
    }

    function setSLimit(uint256 _sLimit)
        external
        onlyRole(CROWD_ROLE)
        isState(CrowdsaleState.Start)
    {
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

    function getLotteries(address star) external view returns (uint256) {
        return lotteries[star];
    }

    function gift(uint256[] memory _lotteries)
        external
        onlyRole(CROWD_ROLE)
        isState(CrowdsaleState.Gift)
    {
        require(
            _lotteries.length == quiz + 1,
            "QuizCrowdsale: The length is not equal to the number of quiz options"
        );
        _changeState(CrowdsaleState.Finish);
        for (uint256 si = 0; si < stars.length(); si++) {
            address star = stars.at(si);
            Quiz[] memory qs = quizzes[star];
            for (uint256 index = 0; index < qs.length; index++) {
                Quiz memory _quiz = qs[index];
                uint256 quantity = _quiz.amount.mul(_lotteries[_quiz.option]);
                if (quantity > 0) {
                    lotteries[star] = lotteries[star].add(quantity);
                    numberOfLotteries = numberOfLotteries.add(quantity);
                }
            }
        }
    }

    function lottery()
        external
        onlyRole(CROWD_ROLE)
        isState(CrowdsaleState.Finish)
        returns (uint256)
    {
        require(
            numberOfLotteries > 0,
            "QuizCrowdsale: The lottery tickets have all been distributed"
        );
        address _lottery = WelfareFactory(welfareFactory).current();
        if (_lottery == address(0)) {
            _lottery = WelfareFactory(welfareFactory).newLottery7();
            Lottery(payable(_lottery)).grantLotteryRole(address(this));
        }
        uint256 numberOftwist = 0;
        for (
            uint256 si = 0;
            si < stars.length() && numberOfLotteries > 0;
            si++
        ) {
            address star = stars.at(si);
            uint256 quantity = lotteries[star];
            if (quantity > 0) {
                uint256 left = Lottery(payable(_lottery)).left();
                if (left <= 0) {
                    _lottery = WelfareFactory(welfareFactory).newLottery7();
                    Lottery(payable(_lottery)).grantLotteryRole(address(this));
                    left = Lottery(payable(_lottery)).left();
                }
                if (quantity > left) {
                    quantity = left;
                    lotteries[star] = lotteries[star].sub(quantity);
                } else {
                    lotteries[star] = 0;
                }
                numberOfLotteries = numberOfLotteries.sub(quantity);
                numberOftwist = numberOftwist.add(quantity);
                Lottery(payable(_lottery)).twist(star, quantity);

                if (numberOftwist >= 300) {
                    break;
                }
            } else {
                stars.remove(star);
            }
        }
        return numberOfLotteries;
    }

    function transferLotteryOwnership(address newOwner) external onlyOwner {
        uint256 _phase = WelfareFactory(welfareFactory).phase();
        for (uint256 pi = 1; pi <= _phase; pi++) {
            address _lottery = WelfareFactory(welfareFactory).getLottery(pi);
            if (_lottery != address(0)) {
                Lottery(payable(_lottery)).transferOwnership(newOwner);
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

    function _changeState(CrowdsaleState _newState) private {
        state = _newState;
        emit CrowdsaleStateChanged(state);
    }
}
