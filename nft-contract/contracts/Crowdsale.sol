// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./eip712/Signer.sol";
import "./nft/NFTERC721A.sol";

contract Crowdsale is Signer, AccessControl {
    using SafeMath for uint256;
    bytes32 public constant GIFT_ROLE = keccak256("GIFT_ROLE");
    NFTERC721A public token;
    bool public opening; // crowdsale opening status
    uint256 private totalGift = 1522;

    event FreeMintingStarted(bool opening);

    constructor() Signer("METAGOAL") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(GIFT_ROLE, _msgSender());
    }

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

    function gift(address[] calldata _accounts, uint256 _quantity)
        external
        onlyRole(GIFT_ROLE)
    {
        require(!opening, "The airdrop is over");
        (bool ok, uint256 result) = totalGift.trySub(
            _accounts.length * _quantity
        );
        require(ok, "Exceed the maximum number of airdrops");
        totalGift = result;
        for (uint256 index = 0; index < _accounts.length; index++) {
            token.mint(_accounts[index], _quantity);
        }
    }
}
