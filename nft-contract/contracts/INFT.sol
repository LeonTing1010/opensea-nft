// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface INFT{

    function mintTo(address recipient) external returns (uint256);

    function remaining() external view returns (uint256);
}