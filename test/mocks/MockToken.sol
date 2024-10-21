// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MockToken {
    function decimals() external pure returns (uint8) {
        return 18;
    }
}
