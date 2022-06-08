//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EIP712Sign.sol";

abstract contract WhitelistSign is EIP712Sign, Ownable {
    // The key used to sign giftlist signatures.
    // We will check to ensure that the key that signed the signature
    // is this one that we expect.
    address whitelistSigningKey = address(0);

    // The typehash for the data type specified in the structured data
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#rationale-for-typehash
    bytes32 public constant MINER_TYPEHASH = keccak256("Miner(address wallet)");

    // constructor(string memory name) EIP712Sign(name) {}

    function setWhitelistSigningKey(address newSigningKey) public onlyOwner {
        whitelistSigningKey = newSigningKey;
    }

    modifier requiresWhitelist(bytes calldata signature) {
        address recoveredAddress = _recover(
            whitelistSigningKey,
            MINER_TYPEHASH,
            signature
        );
        require(recoveredAddress == whitelistSigningKey, "Invalid Signature");
        _;
    }
}
