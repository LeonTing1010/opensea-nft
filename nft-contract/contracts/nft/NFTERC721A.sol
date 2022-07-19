// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "../eip712/NativeMetaTransaction.sol";
import "../eip712/ContextMixin.sol";
import "./ERC721APausable.sol";
import "../opensea/AllowsConfigurableProxy.sol";

contract NFTERC721A is
    ERC721A,
    ERC721ABurnable,
    ERC721AQueryable,
    ERC721APausable,
    AccessControl,
    AllowsConfigurableProxy,
    ContextMixin,
    NativeMetaTransaction
{
    using SafeMath for uint256;
    // Create a new role identifier for the minter role
    bytes32 public constant MINER_ROLE = keccak256("MINER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @dev Base token URI used as a prefix by tokenURI().
    string private baseTokenURI;
    string private collectionURI;

    constructor(address _proxyAddress)
        ERC721A("Renaissance Roar", "ROAR")
        AllowsConfigurableProxy(_proxyAddress, true)
    {
        _initializeEIP712("Renaissance Roar");
        baseTokenURI = "https://cdn.nftstar.com/roar/metadata/";
        collectionURI = "https://cdn.nftstar.com/roar/meta-roar.json";
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function transfer(
        uint256 startTokenId,
        address[] memory _accounts,
        uint256[] memory _quantity
    ) external onlyRole(MINER_ROLE) {
        require(
            _accounts.length == _quantity.length,
            "The two arrays are not equal in length"
        );
        uint256 amount;
        for (uint256 index = 0; index < _quantity.length; index++) {
            amount = amount.add(_quantity[index]);
        }
        uint256 balance = balanceOf(msg.sender);
        require(balance >= amount, "Insufficient balance");
        uint256 tokenId = startTokenId;
        for (uint256 ia = 0; ia < _accounts.length; ia++) {
            for (uint256 iq = 0; iq < _quantity[ia]; iq++) {
                safeTransferFrom(msg.sender, _accounts[ia], tokenId);
                tokenId = tokenId + 1;
            }
        }
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

    function _msgSender()
        internal
        view
        virtual
        override
        returns (address sender)
    {
        return ContextMixin.msgSender();
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

    // function getMsgSender() external view returns (address) {
    //     return _msgSenderERC721A();
    // }

    /**
     * Override isApprovedForAll to auto-approve OS's proxy contract
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool isOperator)
    {
        // if (owner() == _owner && hasRole(MINER_ROLE, _operator)) {
        //     return true;
        // }
        // if OpenSea's ERC721 Proxy Address is detected, auto-return true
        // for Polygon's Mumbai testnet, use 0xff7Ca10aF37178BdD056628eF42fD7F799fAc77c
        // if (_operator == address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE)) {
        //     return true;
        // }
        if (isApprovedForProxy(_owner, _operator)) {
            return true;
        }

        // otherwise, use the default ERC721.isApprovedForAll()
        return ERC721A.isApprovedForAll(_owner, _operator);
    }
}
