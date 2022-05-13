// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./FactoryMintable.sol";
import "./AllowsConfigurableProxy.sol";

contract NFTFactory is
    IERC721,
    AllowsConfigurableProxy,
    Pausable,
    ReentrancyGuard
{
    using Strings for uint256;
    uint256 public NUM_OPTIONS;
    /// @notice Base URI for constructing tokenURI values for options.
    string public optionURI;
    /// @notice Contract that deployed this factory.
    FactoryMintable public token;

    constructor(
        string memory _baseOptionURI,
        address _owner,
        uint256 _numOptions,
        address _proxyAddress
    ) AllowsConfigurableProxy(_proxyAddress, true) {
        token = FactoryMintable(msg.sender);
        NUM_OPTIONS = _numOptions;
        optionURI = _baseOptionURI;
        transferOwnership(_owner);
        createOptionsAndEmitTransfers();
    }

    error NotOwnerOrProxy();
    error InvalidOptionId();

    modifier onlyOwnerOrProxy() {
        if (
            _msgSender() != owner() &&
            !isApprovedForProxy(owner(), _msgSender())
        ) {
            revert NotOwnerOrProxy();
        }
        _;
    }

    modifier checkValidOptionId(uint256 _optionId) {
        // options are 1-indexed so check should be inclusive
        if (_optionId > NUM_OPTIONS) {
            revert InvalidOptionId();
        }
        _;
    }

    modifier interactBurnInvalidOptionId(uint256 _optionId) {
        _;
        _burnInvalidOptions();
    }

    /// @notice Sets the nft address for FactoryMintable.
    function setNFT(address _token) external onlyOwner {
        token = FactoryMintable(_token);
    }

    /// @notice Sets the base URI for constructing tokenURI values for options.
    function setBaseOptionURI(string memory _baseOptionURI) public onlyOwner {
        optionURI = _baseOptionURI;
    }

    /**
    @notice Returns a URL specifying option metadata, conforming to standard
    ERC1155 metadata format.
     */
    function tokenURI(uint256 _optionId) external view returns (string memory) {
        return string(abi.encodePacked(optionURI, _optionId.toString()));
    }

    /**
    @dev Return true if operator is an approved proxy of Owner
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool)
    {
        return isApprovedForProxy(_owner, _operator);
    }

    ///@notice public facing method for _burnInvalidOptions in case state of tokenContract changes
    function burnInvalidOptions() public onlyOwner {
        _burnInvalidOptions();
    }

    ///@notice "burn" option by sending it to 0 address. This will hide all active listings. Called as part of interactBurnInvalidOptionIds
    function _burnInvalidOptions() internal {
        for (uint256 i = 1; i <= NUM_OPTIONS; ++i) {
            if (!token.factoryCanMint(i)) {
                emit Transfer(owner(), address(0), i);
            }
        }
    }

    /**
    @notice emit a transfer event for a "burn" option back to the owner if factoryCanMint the optionId
    @dev will re-validate listings on OpenSea frontend if an option becomes eligible to mint again
    eg, if max supply is increased
    */
    function restoreOption(uint256 _optionId) external onlyOwner {
        if (token.factoryCanMint(_optionId)) {
            emit Transfer(address(0), owner(), _optionId);
        }
    }

    /**
    @notice Emits standard ERC721.Transfer events for each option so NFT indexers pick them up.
    Does not need to fire on contract ownership transfer because once the tokens exist, the `ownerOf`
    check will always pass for contract owner.
     */
    function createOptionsAndEmitTransfers() internal {
        for (uint256 i = 1; i <= NUM_OPTIONS; i++) {
            emit Transfer(address(0), owner(), i);
        }
    }

    function approve(address operator, uint256) external override onlyOwner {
        setProxyAddress(operator);
    }

    function getApproved(uint256)
        external
        view
        override
        returns (address operator)
    {
        return proxyAddress();
    }

    function setApprovalForAll(address operator, bool)
        external
        override
        onlyOwner
    {
        setProxyAddress(operator);
    }

    function supportsFactoryInterface() public pure returns (bool) {
        return true;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function balanceOf(address _owner)
        external
        view
        override
        returns (uint256)
    {
        return _owner == owner() ? NUM_OPTIONS : 0;
    }

    /**
    @notice Returns owner if _optionId is valid so posted orders pass validation
     */
    function ownerOf(uint256 _optionId) public view override returns (address) {
        return token.factoryCanMint(_optionId) ? owner() : address(0);
    }

    function safeTransferFrom(
        address,
        address _to,
        uint256 _optionId
    )
        public
        override
        nonReentrant
        onlyOwnerOrProxy
        whenNotPaused
        interactBurnInvalidOptionId(_optionId)
    {
        token.factoryMint(_optionId, _to);
    }

    function safeTransferFrom(
        address,
        address _to,
        uint256 _optionId,
        bytes calldata
    ) external override {
        safeTransferFrom(_to, _to, _optionId);
    }

    /**
    @notice hack: transferFrom is called on sale , this method mints the real token
     */
    function transferFrom(
        address,
        address _to,
        uint256 _optionId
    )
        public
        override
        nonReentrant
        onlyOwnerOrProxy
        whenNotPaused
        interactBurnInvalidOptionId(_optionId)
    {
        token.factoryMint(_optionId, _to);
    }
}
