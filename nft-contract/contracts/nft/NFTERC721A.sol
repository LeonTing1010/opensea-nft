// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "erc721a/contracts/extensions/ERC721AOwnersExplicit.sol";
import "../eip712/NativeMetaTransaction.sol";
import "../eip712/ContextMixin.sol";
import "./ERC721APausable.sol";

contract NFTERC721A is
    ERC721A,
    ERC721ABurnable,
    ERC721AQueryable,
    ERC721AOwnersExplicit,
    ERC721APausable,
    AccessControl,
    Ownable,
    ContextMixin,
    NativeMetaTransaction
{
    // Create a new role identifier for the minter role
    bytes32 public constant MINER_ROLE = keccak256("MINER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    // using Counters for Counters.Counter;
    // Counters.Counter private currentTokenId;
    /// @dev Base token URI used as a prefix by tokenURI().
    string private baseTokenURI;
    string private collectionURI;

    // uint256 public constant TOTAL_SUPPLY = 10800;

    constructor() ERC721A("SONNY-BOOT", "HM-SON-BOOT") {
        _initializeEIP712("SONNY-BOOT");
        baseTokenURI = "https://cdn.nftstar.com/hm-son-boot/metadata/";
        collectionURI = "https://cdn.nftstar.com/hm-son/meta-son-heung-min.json";
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    // function totalSupply() public view override returns (uint256) {
    //     return TOTAL_SUPPLY;
    // }

    // function remaining() public view returns (uint256) {
    //     return TOTAL_SUPPLY - _totalMinted();
    // }

    function mintTo(address to) public onlyRole(MINER_ROLE) {
        _safeMint(to, 1);
    }

    function mint(address to, uint256 quantity) public onlyRole(MINER_ROLE) {
        _safeMint(to, quantity);
    }

    // function gift(address[] memory _accounts, uint256 _amount)
    //     external
    //     onlyRole(MINER_ROLE)
    // {
    //     for (uint256 c = 0; c < _accounts.length; c++) {
    //         mint(_accounts[c], _amount);
    //     }
    // }

    /**
     * tokensOfOwner
     */
    // function ownerTokens(address owner) public view returns (uint256[] memory) {
    //     return tokensOfOwner(owner);
    // }

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
        return _totalMinted();
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
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
        override(AccessControl, ERC721A)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override(ERC721A, ERC721APausable) {
        super._beforeTokenTransfers(from, to, startTokenId, quantity);
    }

    function _msgSender()
        internal
        view
        virtual
        override
        returns (address sender)
    {
        return ContextMixin.msgSender();
    }
}
