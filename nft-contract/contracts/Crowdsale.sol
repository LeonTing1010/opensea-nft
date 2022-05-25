// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./eip712/GiftEIP712Signer.sol";
import "./nft/NFTERC721A.sol";

contract Crowdsale is GiftSigner {
    using SafeMath for uint256;

    NFTERC721A public token;
    bool public opening; // crowdsale opening status
    uint256 public TOTAL_SUPPLY = 777;

    mapping(address => bool) free;

    event FreeMintingStarted(bool opening);

    constructor() GiftSigner("SONNY-BOOT") {}

    function mint(bytes calldata signature)
        external
        requiresSignature(signature)
    {
        require(!opening, "Free mining has not yet begun");
        address miner = msg.sender;
        require(free[miner], "Already mined");
        require(token.current() <= TOTAL_SUPPLY, "Exceeded maximum supply");
        free[miner] = true;
        token.mint(miner, 1);
    }

    function mined(address _account) public view returns (bool) {
        return free[_account];
    }

    function setNft(address _nft) external onlyOwner {
        require(_nft != address(0), "Invalid address");
        token = NFTERC721A(_nft);
    }

    function setTotalSupply(uint256 _totalSupply) external onlyOwner {
        if (_totalSupply <= 0) {
            revert();
        }
        TOTAL_SUPPLY = _totalSupply;
    }

    function setOpening(bool _opening) external onlyOwner {
        opening = _opening;
        emit FreeMintingStarted(opening);
    }

    function remaining() external view returns (uint256) {
        return TOTAL_SUPPLY - token.current();
    }
}
