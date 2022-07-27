// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IRandomConsumer {
    function onRandomWords(uint256 requestId, uint256[] memory randomWords)
        external;
}
