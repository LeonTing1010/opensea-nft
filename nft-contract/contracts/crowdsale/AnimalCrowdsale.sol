// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "../nft/Animal.sol";
import "../nft/Human.sol";
import "../nft/Potion.sol";
import "../nft/Halfling.sol";

contract AnimalCrowdsale is AccessControl, Ownable {
    using SafeMath for uint256;
    bytes32 public constant CROWD_ROLE = keccak256("CROWD_ROLE");
    address public token;
    address public human;
    address public potion;
    address public halfling;
    bool public allowed;

    event AllowSaleStarted(bool started);
    /**
     * The caller must own the token.
     */
    error CallerNotOwner(address potionOwner, address halflingOwner);

    constructor(
        address _nft,
        address _human,
        address _potion,
        address _halfling
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CROWD_ROLE, msg.sender);
        setNft(_nft);
        human = _human;
        potion = _potion;
        halfling = _halfling;
    }

    function mint(uint256 _potionId, uint256 _halflingId) external {
        address pOwner = ERC721A(potion).ownerOf(_potionId);
        address hOwner = ERC721A(halfling).ownerOf(_halflingId);
        if (msg.sender != pOwner || msg.sender != hOwner) {
            revert CallerNotOwner(pOwner, hOwner);
        }
        ERC721ABurnable(potion).burn(_potionId);
        ERC721ABurnable(halfling).burn(_halflingId);
        Animal(token).mint(msg.sender, 1);
    }

    function setNft(address _nft) public onlyRole(CROWD_ROLE) {
        require(_nft != address(0), "AnimalCrowdsale:Invalid address");
        token = _nft;
    }

    function setAllow(bool _allow) external onlyRole(CROWD_ROLE) {
        allowed = _allow;
        emit AllowSaleStarted(_allow);
    }

    function transferRoleAdmin(address newDefaultAdmin)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            newDefaultAdmin != address(0),
            "AnimalCrowdsale:Invalid address"
        );
        _setupRole(DEFAULT_ADMIN_ROLE, newDefaultAdmin);
    }
}
