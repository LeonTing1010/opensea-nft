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

    event FreeMintingStarted(bool opening);

    constructor() Signer("Tiger") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(GIFT_ROLE, msg.sender);
    }

    function mint(uint256 amount, bytes calldata signature)
        external
        requiresSignature(signature)
    {
        require(opening, "Free mining has not yet begun");
        token.mint(msg.sender, amount);
    }

    function setNft(address _nft) external onlyRole(GIFT_ROLE) {
        require(_nft != address(0), "Invalid address");
        token = NFTERC721A(_nft);
    }

    function setOpening(bool _opening) external onlyRole(GIFT_ROLE) {
        opening = _opening;
        emit FreeMintingStarted(opening);
    }

    function current() external view returns (uint256) {
        return token.current();
    }

    function gift(address[] calldata _accounts, uint256[] calldata _quantity)
        external
        onlyRole(GIFT_ROLE)
    {
        require(!opening, "The airdrop is over");
        require(
            _accounts.length == _quantity.length,
            "The two arrays are not equal in length"
        );
        for (uint256 index = 0; index < _accounts.length; index++) {
            token.mint(_accounts[index], _quantity[index]);
        }
    }
}
