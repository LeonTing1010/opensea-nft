// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IAfterTokenTransfer {
    function onTokenMinted(
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) external;
}
