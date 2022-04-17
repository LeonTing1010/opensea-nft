// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./NFT.sol";
import "./NFTFactory.sol";
import "./FactoryMintable.sol";
import "./AllowsConfigurableProxy.sol";

contract NFTFactoryERC721 is
    NFT,
    FactoryMintable,
    ReentrancyGuard,
    AllowsConfigurableProxy
{
    using Strings for uint256;
    uint256 public maxSupply;

    constructor(address _proxyAddress)
        AllowsConfigurableProxy(_proxyAddress, true)
    {
        maxSupply = totalSupply();
        tokenFactory = address(
            new NFTFactory("ipfs://options", owner(), 5, _proxyAddress)
        );
        _setupRole(MINER_ROLE, tokenFactory);
    }

    function factoryMint(uint256 _optionId, address _to)
        public
        override
        nonReentrant
        onlyFactory
        canMint(_optionId)
    {
        for (uint256 i; i < _optionId; ++i) {
            mintTo(_to);
        }
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
}
