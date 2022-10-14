// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {AavePool} from './interfaces/AaavePool.sol';
import {WMatic} from './interfaces/WMatic.sol';
import {YieldOffseterFactory} from './YieldOffseterFactory.sol';

/// @title YieldOffseterVault
contract YieldOffseterVault {
    /// interface to the YieldOffseterFactory
    YieldOffseterFactory public immutable yieldOffseterFactory;

    /// interface to the Aave pool
    AavePool public immutable aavePool;

    /// interface to the WMATIC token
    WMatic public immutable wMatic;

    /// amounts of deposited WMATIC by each user into the YieldOffseter
    /// @dev TODO could be turned into a nested mapping to allow multiple assets to be deposited
    mapping(address => uint256) public deposits;

    /// Only the owner of the YieldOffseterVault can call this function
    modifier onlyVaultOwner() {
        require(address(this) == yieldOffseterFactory.getVault(msg.sender), 'not your vault');
        _;
    }

    /// @dev TODO this is not supposed to be deployable by anyone but the YieldOffseterFactory
    constructor(address _aavePool, address _wmatic) {
        yieldOffseterFactory = YieldOffseterFactory(msg.sender);
        aavePool = AavePool(_aavePool);
        wMatic = WMatic(_wmatic);
    }

    /// @notice Deposit an `amount` of MATIC, to be later supplied to the Aave pool as WMATIC
    /// @param _amount Amount of tokens to be supplied
    function deposit(uint256 _amount) public payable onlyVaultOwner {}

    /// @notice Supplies the Aave pool with an amount of deposited WMATIC
    /// @param _amount Amount to be supplied
    function supply(uint256 _amount) public onlyVaultOwner {}

    /// @notice Calculates the amount of yield earned by the caller
    /// @return Amount of WMATIC extra of the supplied amount
    function calculateYield() public view onlyVaultOwner returns (uint256) {}

    /// @notice Withdraws the earned yield from the Aave pool & uses it to offset CO2 emissions through the OffsetHelper
    function offsetYield() public onlyVaultOwner {}

    /// @notice Withdraws the supplied WMATIC from the AavePool into the YieldOffseter
    /// @param _amount Amount to be withdrawn
    function withdraw(uint256 _amount) public onlyVaultOwner {}

    /// @notice Withdraws the deposited WMATIC from the YieldOffseter
    /// @param _amount Amount to be withdrawn
    function withdraw2(uint256 _amount) public onlyVaultOwner {}
}
