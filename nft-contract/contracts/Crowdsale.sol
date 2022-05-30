// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./eip712/Signer.sol";
import "./nft/NFTERC721A.sol";

contract Crowdsale is Signer {
    using SafeMath for uint256;

    NFTERC721A public token;
    bool public opening; // crowdsale opening status

    mapping(address => bool) free;

    event FreeMintingStarted(bool opening);

    constructor() Signer("METAGOAL") {}

    function mint(uint256 amount, bytes calldata signature)
        external
        requiresSignature(signature)
    {
        require(opening, "Free mining has not yet begun");
        token.mint(msg.sender, amount);
    }

    function setNft(address _nft) external onlyOwner {
        require(_nft != address(0), "Invalid address");
        token = NFTERC721A(_nft);
    }

    function setOpening(bool _opening) external onlyOwner {
        opening = _opening;
        emit FreeMintingStarted(opening);
    }

    function current() external view returns (uint256) {
        return token.current();
    }
}
