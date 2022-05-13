// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/Context.sol";
import "./IFactoryMintable.sol";

abstract contract FactoryMintable is IFactoryMintable, Context {
    address public tokenFactory;

    error NotTokenFactory();
    error FactoryCannotMint();

    modifier onlyFactory() {
        if (_msgSender() != tokenFactory) {
            revert NotTokenFactory();
        }
        _;
    }

    modifier canMint(uint256 _optionId) {
        if (!factoryCanMint(_optionId)) {
            revert FactoryCannotMint();
        }
        _;
    }

    function factoryMint(uint256 _optionId, address _to)
        external
        virtual
        override;

    function factoryCanMint(uint256 _optionId)
        public
        view
        virtual
        override
        returns (bool);
}
