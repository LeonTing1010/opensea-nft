// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./ContextMixin.sol";
import "./NativeMetaTransaction.sol";
import "./INFT.sol";

contract NFTERC721 is
    ERC721,
    ERC721Burnable,
    ERC721Pausable,
    ERC721Enumerable,
    AccessControl,
    Ownable,
    ContextMixin,
    NativeMetaTransaction
{
    // Create a new role identifier for the minter role
    bytes32 public constant MINER_ROLE = keccak256("MINER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;
    /// @dev Base token URI used as a prefix by tokenURI().
    string private baseTokenURI;
    string private collectionURI;

    // uint256 public constant TOTAL_SUPPLY = 10800;

    constructor() ERC721("elephant", "ELT") {
        _initializeEIP712("elephant");
        baseTokenURI = "https://cdn.nftstar.com/hm-son/metadata/";
        collectionURI = "https://cdn.nftstar.com/hm-son/meta-son-heung-min.json";
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function remaining() public view returns (uint256) {
        return totalSupply() - currentTokenId.current();
    }

    function mintTo(address recipient)
        public
        onlyRole(MINER_ROLE)
        returns (uint256)
    {
        // uint256 tokenId = currentTokenId.current();
        // require(tokenId < TOTAL_SUPPLY, "Max supply reached");
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    function ownerTokens(address owner) public view returns (uint256[] memory) {
        uint256 size = ERC721.balanceOf(owner);
        uint256[] memory items = new uint256[](size);
        for (uint256 i = 0; i < size; i++) {
            items[i] = tokenOfOwnerByIndex(owner, i);
        }
        return items;
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "NFT: must have pauser role to pause"
        );
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "NFT: must have pauser role to unpause"
        );
        _unpause();
    }

    function current() public view returns (uint256) {
        return currentTokenId.current();
    }

    function contractURI() public view returns (string memory) {
        return collectionURI;
    }

    function setContractURI(string memory _contractURI) public onlyOwner {
        collectionURI = _contractURI;
    }

    /// @dev Returns an URI for a given token ID
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /// @dev Sets the base token URI prefix.
    function setBaseTokenURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function transferRoleAdmin(address newDefaultAdmin)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, newDefaultAdmin);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC721, ERC721Pausable, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _msgSender() internal view override returns (address sender) {
        return ContextMixin.msgSender();
    }
}
