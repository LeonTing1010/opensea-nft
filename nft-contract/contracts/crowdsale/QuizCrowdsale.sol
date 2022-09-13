// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract QuizCrowdsale is AccessControl, Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    bytes32 public constant CROWD_ROLE = keccak256("CROWD_ROLE");
    bool public opening; // airdrop opening status
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
    event QuizMinted(uint256 indexed tokenId, uint256 mat, uint8 opt);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CROWD_ROLE, msg.sender);
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
        uint256[] calldata _tokenIds,
        uint256[] calldata _matches,
        uint8[] calldata _options
    ) external onlyRole(CROWD_ROLE) {
        require(opening, "QuizCrowdsale: Public sale has ended");
        require(
            _matches.length == _options.length &&
                _tokenIds.length == _options.length,
            "QuizCrowdsale: Array length is inconsistent"
        );
        for (uint256 index = 0; index < _options.length; index++) {
            require(
                !matches.contains(_matches[index]),
                "QuizCrowdsale: The match has been banned from betting"
            );
            quizzes[_tokenIds[index]] = Quiz(_matches[index], _options[index]);
            emit QuizMinted(_tokenIds[index], _matches[index], _options[index]);
        }
    }

    function setOpening(bool _opening) external onlyRole(CROWD_ROLE) {
        require(opening != _opening);
        opening = _opening;
        emit PubSaleStarted(opening);
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
