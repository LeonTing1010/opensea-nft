//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EIP712Sign.sol";

abstract contract GiftlistSign is EIP712Sign, Ownable {
    // The key used to sign giftlist signatures.
    // We will check to ensure that the key that signed the signature
    // is this one that we expect.
    address giftlistSigningKey = address(0);

    // The typehash for the data type specified in the structured data
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#rationale-for-typehash
    bytes32 public constant GIFT_TYPEHASH = keccak256("Gift(address wallet)");

    // constructor(string memory name) EIP712Sign(name) {}

    function setGiftlistSigningKey(address newSigningKey) public onlyOwner {
        giftlistSigningKey = newSigningKey;
    }

    modifier requiresGiftlist(bytes calldata signature) {
        address recoveredAddress = _recover(
            giftlistSigningKey,
            GIFT_TYPEHASH,
            signature
        );
        require(recoveredAddress == giftlistSigningKey, "Invalid Signature");
        _;
    }
}
