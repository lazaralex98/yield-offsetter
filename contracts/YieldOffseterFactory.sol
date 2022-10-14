// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {YieldOffseterVault} from './YieldOffseterVault.sol';

/// @title YieldOffseterFactory
contract YieldOffseterFactory {
    /// each user is entitled to only 1 YieldOffseterVault
    mapping(address => address) private vaults;

    /// @notice Creates a YieldOffseterVault for the caller
    function createVault() public returns (address) {}

    /// @notice Returns the YieldOffseterVault for `_guy`
    /// @param _guy Address of the vault owner
    /// @return Address of the YieldOffseterVault that `_guy` owns
    function getVault(address _guy) public view returns (address) {}
}
