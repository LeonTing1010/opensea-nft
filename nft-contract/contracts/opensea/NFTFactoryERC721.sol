// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../nft/NFTERC721A.sol";
import "./NFTFactory.sol";
import "./FactoryMintable.sol";
import "./AllowsConfigurableProxy.sol";

contract NFTFactoryERC721 is
    NFTERC721A,
    FactoryMintable,
    ReentrancyGuard,
    AllowsConfigurableProxy
{
    using Strings for uint256;
    uint256 public maxSupply;

    error NewMaxSupplyMustBeGreater();

    constructor(address _proxyAddress)
        AllowsConfigurableProxy(_proxyAddress, true)
    {
        maxSupply = totalSupply();
        tokenFactory = address(
            new NFTFactory(
                "https://cdn.nftstar.com/hm-son-mint/metadata/",
                owner(),
                5,
                _proxyAddress
            )
        );
        _setupRole(MINER_ROLE, tokenFactory);
        //emit Transfer(address(0), owner(), 0);
    }

    function factoryMint(uint256 _optionId, address _to)
        public
        override
        nonReentrant
        onlyFactory
        canMint(_optionId)
    {
        mint(_to, _optionId);
    }

    function factoryCanMint(uint256 _optionId)
        public
        view
        virtual
        override
        returns (bool)
    {
        if (_optionId == 0 || _optionId > maxSupply) {
            return false;
        }
        if (_optionId > (maxSupply - current())) {
            return false;
        }
        return true;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        if (_maxSupply <= maxSupply) {
            revert NewMaxSupplyMustBeGreater();
        }
        maxSupply = _maxSupply;
    }

    function _msgSender()
        internal
        view
        override(Context, NFTERC721A)
        returns (address sender)
    {
        return ContextMixin.msgSender();
    }
}
