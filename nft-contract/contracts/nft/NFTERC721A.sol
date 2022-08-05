// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "../eip712/NativeMetaTransaction.sol";
import "../eip712/ContextMixin.sol";
import "./ERC721APausable.sol";
import "./IAfterTokenTransfer.sol";

contract NFTERC721A is
    ERC721A,
    ERC721ABurnable,
    ERC721AQueryable,
    ERC721APausable,
    AccessControl,
    ContextMixin,
    NativeMetaTransaction
{
    // Create a new role identifier for the minter role
    bytes32 public constant MINER_ROLE = keccak256("MINER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @dev Base token URI used as a prefix by tokenURI().
    string private baseTokenURI;
    string private collectionURI;

    address private callback;

    constructor() ERC721A("Renaissance Roar", "ROAR") {
        _initializeEIP712("Renaissance Roar");
        baseTokenURI = "https://cdn.nftstar.com/roar/metadata/";
        collectionURI = "https://cdn.nftstar.com/roar/meta-roar.json";
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSenderERC721A());
        _setupRole(MINER_ROLE, _msgSenderERC721A());
        _setupRole(PAUSER_ROLE, _msgSenderERC721A());
    }

    function gift(address[] calldata _accounts, uint256[] calldata _quantities)
        external
        onlyRole(MINER_ROLE)
    {
        require(
            _accounts.length == _quantities.length,
            "NFTERC721A: The two arrays are not equal in length"
        );
        for (uint256 index = 0; index < _accounts.length; index++) {
            _mint(_accounts[index], _quantities[index]);
        }
    }

    function mintTo(address to) public onlyRole(MINER_ROLE) {
        _safeMint(to, 1);
    }

    function mint(address to, uint256 quantity) public onlyRole(MINER_ROLE) {
        _safeMint(to, quantity);
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
            "NFTERC721A: must have pauser role to pause"
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
            "NFTERC721A: must have pauser role to unpause"
        );
        _unpause();
    }

    function current() public view returns (uint256) {
        return _totalMinted();
    }

    function nextTokenId() public view returns (uint256) {
        return _nextTokenId();
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function contractURI() public view returns (string memory) {
        return collectionURI;
    }

    function setContractURI(string memory _contractURI)
        external
        onlyRole(MINER_ROLE)
    {
        collectionURI = _contractURI;
    }

    /// @dev Returns an URI for a given token ID
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /// @dev Sets the base token URI prefix.
    function setBaseTokenURI(string memory _baseTokenURI)
        external
        onlyRole(MINER_ROLE)
    {
        baseTokenURI = _baseTokenURI;
    }

    function setAfterTransfer(address _transfer) external onlyRole(MINER_ROLE) {
        require(_transfer != address(0), "NFTERC721A: Invalid address");
        callback = _transfer;
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
        return
            super.supportsInterface(interfaceId) ||
            ERC721A.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override(ERC721A, ERC721APausable) {
        super._beforeTokenTransfers(from, to, startTokenId, quantity);
    }

    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        if (from == address(0)) {
            IAfterTokenTransfer(callback).onTokenMinted(
                to,
                startTokenId,
                quantity
            );
        }
        super._afterTokenTransfers(from, to, startTokenId, quantity);
    }

    function _msgSenderERC721A()
        internal
        view
        virtual
        override
        returns (address sender)
    {
        return ContextMixin.msgSender();
    }
}
