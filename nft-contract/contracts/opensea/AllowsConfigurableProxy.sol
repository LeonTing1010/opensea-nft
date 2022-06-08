// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IAllowsProxy.sol";

contract OwnableDelegateProxy {}

/**
 * Used to delegate ownership of a contract to another address, to save on unneeded transactions to approve contract use for users
 */
contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract AllowsConfigurableProxy is IAllowsProxy, Ownable {
    bool internal isProxyActive_;
    address internal proxyAddress_;

    constructor(address _proxyAddress, bool _isProxyActive) {
        proxyAddress_ = _proxyAddress;
        isProxyActive_ = _isProxyActive;
    }

    function setIsProxyActive(bool _isProxyActive) external onlyOwner {
        isProxyActive_ = _isProxyActive;
    }

    function setProxyAddress(address _proxyAddress) public onlyOwner {
        proxyAddress_ = _proxyAddress;
    }

    function proxyAddress() public view override returns (address) {
        return proxyAddress_;
    }

    function isProxyActive() public view override returns (bool) {
        return isProxyActive_;
    }

    function isApprovedForProxy(address owner, address _operator)
        public
        view
        override
        returns (bool)
    {
        if (isProxyActive_ && proxyAddress_ == _operator) {
            return true;
        }
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyAddress_);
        if (
            isProxyActive_ && address(proxyRegistry.proxies(owner)) == _operator
        ) {
            return true;
        }
        return false;
    }
}
