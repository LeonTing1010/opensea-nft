// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../nft/NFTERC721A.sol";
import "../lottery/Lottery.sol";

contract QuizCrowdsale is AccessControl, PullPayment, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    bytes32 public constant CROWD_ROLE = keccak256("CROWD_ROLE");
    address public token;
    bool public opening; // airdrop opening status
    uint256 public sLimit = 10; //single mint limit
    uint256 public mLimit = 1000; //total mining limit
    uint256 public salePrice = 0.01 ether;
    address public collector;
    uint256 public totalMinted;
    address payable public lottery;
    mapping(uint256 => Quiz) quizzes; // tokenId->Quiz
    EnumerableSet.UintSet matches;
    struct Quiz {
        uint256 mat;
        uint8 option;
    }

    event PubSaleStarted(bool opening);
    event SalePriceChanged(uint256 price);
    event MLimitChanged(uint256 mLimit);
    event SLimitChanged(uint256 sLimit);
    event CollectorChanged(address collector);
    event QuizMinted(
        address indexed to,
        uint256 mat,
        uint8 opt,
        address lottery
    );
    event LotteryChanged(address lottery, address newLottery);

    constructor(address _collector, address _nft) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CROWD_ROLE, msg.sender);
        collector = _collector;
        token = _nft;
    }

    function endBet(uint256[] calldata _matches) external onlyRole(CROWD_ROLE) {
        for (uint256 index = 0; index < _matches.length; index++) {
            matches.add(_matches[index]);
        }
    }

    function banned(uint256 _match) external view returns (bool) {
        return matches.contains(_match);
    }

    function bet(
        uint256 _amount,
        uint256[] calldata _matches,
        uint8[] calldata _options
    ) external payable nonReentrant {
        require(opening, "QuizCrowdsale: Public sale has ended");
        require(
            _matches.length == _options.length && _amount == _options.length,
            "QuizCrowdsale: The number of matches&options is less than the current amount"
        );
        require(
            _amount <= sLimit,
            "QuizCrowdsale: Exceeded the single purchase limit"
        );
        require(
            msg.value == _amount.mul(salePrice),
            "QuizCrowdsale: Payment declined"
        );
        totalMinted = totalMinted.add(_amount);
        require(
            totalMinted <= mLimit,
            "QuizCrowdsale: Exceeded the total amount of mining"
        );
        uint256 startTokenId = NFTERC721A(token).nextTokenId();
        address star = msg.sender;
        for (uint256 index = 0; index < _options.length; index++) {
            require(
                !matches.contains(_matches[index]),
                "QuizCrowdsale: The match has been banned from betting"
            );
            uint256 tokenId = startTokenId + index;
            quizzes[tokenId] = Quiz(_matches[index], _options[index]);
            emit QuizMinted(star, _matches[index], _options[index], lottery);
        }
        _asyncTransfer(collector, msg.value);
        NFTERC721A(token).mint(star, _amount);
    }

    function setNft(address _nft) public onlyRole(CROWD_ROLE) {
        require(_nft != address(0), "QuizCrowdsale: Invalid address");
        token = _nft;
    }

    function setLottery(address payable _lottery) public onlyRole(CROWD_ROLE) {
        require(
            _lottery != address(0) && lottery != _lottery,
            "QuizCrowdsale: Invalid address"
        );
        require(!opening, "QuizCrowdsale: The sale is not over yet");
        emit LotteryChanged(lottery, _lottery);
        lottery = _lottery;
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

    function getQuizes(uint256 tokenId) external view returns (Quiz memory) {
        return quizzes[tokenId];
    }
}
