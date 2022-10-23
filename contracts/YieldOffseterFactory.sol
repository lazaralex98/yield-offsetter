// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {AavePool} from './interfaces/AaavePool.sol';
import {WMatic} from './interfaces/WMatic.sol';
import {YieldOffseterVault} from './YieldOffseterVault.sol';
import {Errors} from './libraries/Errors.sol';

/// @title YieldOffseterFactory
contract YieldOffseterFactory {
    // ============================================
    // ================ State vars ================
    // ============================================

    /// interface to the Aave pool
    AavePool public immutable aavePool;

    /// interface to the WMATIC token
    WMatic public immutable wMatic;

    /// each user is entitled to only 1 YieldOffseterVault
    mapping(address => address) private vaults;

    // ============================================
    // ================== Events ==================
    // ============================================

    /// @notice Emitted when a new YieldOffseterVault is created
    /// @param owner Owner of the YieldOffseterVault
    /// @param vault Address of the YieldOffseterVault
    event VaultCreated(address indexed owner, address indexed vault);

    // ============================================
    // ================ Constructor ===============
    // ============================================

    /// @dev TODO this is not supposed to be deployable by anyone but the YieldOffseterFactory
    constructor(address aavePoolAddress, address wmaticAddress) {
        aavePool = AavePool(aavePoolAddress);
        wMatic = WMatic(wmaticAddress);
    }

    // ============================================
    // =============== Public funcs ===============
    // ============================================

    /// @notice Creates a YieldOffseterVault for the caller
    /// @return Address of the newly created YieldOffseterVault
    function createVault() public returns (address) {
        require(vaults[msg.sender] == address(0), Errors.F_ALREADY_HAVE_VAULT);
        YieldOffseterVault newVault = new YieldOffseterVault(address(aavePool), address(wMatic));
        vaults[msg.sender] = address(newVault);
        emit VaultCreated(msg.sender, vaults[msg.sender]);
        return vaults[msg.sender];
    }

    /// @notice Returns the YieldOffseterVault for `guy`
    /// @param guy Address of the vault owner
    /// @return Address of the YieldOffseterVault that `guy` owns
    function getVault(address guy) public view returns (address) {
        return vaults[guy];
    }
}
