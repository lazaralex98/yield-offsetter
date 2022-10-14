// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {AavePool} from './interfaces/AaavePool.sol';
import {WMatic} from './interfaces/WMatic.sol';
import {YieldOffseterVault} from './YieldOffseterVault.sol';

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
    /// @param _owner Owner of the YieldOffseterVault
    /// @param _vault Address of the YieldOffseterVault
    event VaultCreated(address indexed _owner, address indexed _vault);

    // ============================================
    // ================ Constructor ===============
    // ============================================

    /// @dev TODO this is not supposed to be deployable by anyone but the YieldOffseterFactory
    constructor(address _aavePool, address _wmatic) {
        aavePool = AavePool(_aavePool);
        wMatic = WMatic(_wmatic);
    }

    // ============================================
    // =============== Public funcs ===============
    // ============================================

    /// @notice Creates a YieldOffseterVault for the caller
    /// @return Address of the newly created YieldOffseterVault
    function createVault() public returns (address) {
        require(vaults[msg.sender] == address(0), 'vault already exists');
        YieldOffseterVault newVault = new YieldOffseterVault(address(aavePool), address(wMatic));
        vaults[msg.sender] = address(newVault);
        emit VaultCreated(msg.sender, vaults[msg.sender]);
        return vaults[msg.sender];
    }

    /// @notice Returns the YieldOffseterVault for `_guy`
    /// @param _guy Address of the vault owner
    /// @return Address of the YieldOffseterVault that `_guy` owns
    function getVault(address _guy) public view returns (address) {
        return vaults[_guy];
    }
}
