// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {AavePool} from './interfaces/AaavePool.sol';
import {WMatic} from './interfaces/WMatic.sol';
import {YieldOffseterFactory} from './YieldOffseterFactory.sol';

/// @title YieldOffseterVault
contract YieldOffseterVault {
    // ============================================
    // ================ State vars ================
    // ============================================

    /// interface to the YieldOffseterFactory
    YieldOffseterFactory public immutable yieldOffseterFactory;

    /// interface to the Aave pool
    AavePool public immutable aavePool;

    /// interface to the WMATIC token
    WMatic public immutable wMatic;

    /// amounts of deposited WMATIC by each user into the YieldOffseter
    /// @dev TODO could be turned into a nested mapping to allow multiple assets to be deposited
    mapping(address => uint256) public deposits;

    // ============================================
    // ================ Modifiers =================
    // ============================================

    /// Only the owner of the YieldOffseterVault can call this function
    modifier onlyVaultOwner() {
        require(address(this) == yieldOffseterFactory.getVault(msg.sender), 'not your vault');
        _;
    }

    // ============================================
    // ================== Events ==================
    // ============================================

    /// @notice Emitted when a user deposits MATIC into the YieldOffseterVault
    /// @param guy Address of the depositor
    /// @param amount Amount of MATIC deposited
    event Deposit(address indexed guy, uint256 amount);

    // ============================================
    // ================ Constructor ===============
    // ============================================

    /// @dev TODO this is not supposed to be deployable by anyone but the YieldOffseterFactory
    constructor(address aavePoolAddress, address wmaticAddress) {
        yieldOffseterFactory = YieldOffseterFactory(msg.sender);
        aavePool = AavePool(aavePoolAddress);
        wMatic = WMatic(wmaticAddress);
    }

    // ============================================
    // =============== Public funcs ===============
    // ============================================

    /// @notice Send an amount of MATIC, that gets stored as WMATIC in this vault
    /// @dev TODO I'm keeping this MATIC native deposits because 1. it won't matter if we go multi-asset 2. Toucan offseting can only be done on Polygon for now
    function deposit() public payable onlyVaultOwner {
        deposits[msg.sender] += msg.value;
        wMatic.deposit{value: msg.value}();
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Supplies the Aave pool with an amount of deposited WMATIC
    /// @param amount Amount to be supplied
    function supply(uint256 amount) public onlyVaultOwner {}

    /// @notice Calculates the amount of yield earned by the caller
    /// @return Amount of WMATIC extra of the supplied amount
    function checkYield() public view onlyVaultOwner returns (uint256) {}

    /// @notice Calculates how much CO2 your current yield could offset
    /// @return Amount of CO2 that could be offset by the current yield
    function calculateOffsetable() public view onlyVaultOwner returns (uint256) {}

    /// @notice Withdraws the earned yield from the Aave pool & uses it to offset CO2 emissions through the OffsetHelper
    function offsetYield() public onlyVaultOwner {}

    /// @notice Withdraws the supplied WMATIC from the AavePool into the YieldOffseter
    /// @param amount Amount to be withdrawn
    function withdraw(uint256 amount) public onlyVaultOwner {}

    /// @notice Withdraws the deposited WMATIC from the YieldOffseter
    /// @param amount Amount to be withdrawn
    function withdraw2(uint256 amount) public onlyVaultOwner {}
}
