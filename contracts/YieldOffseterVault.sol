// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {SafeMath} from '@openzeppelin/contracts/utils/math/SafeMath.sol';

import {AavePool} from './interfaces/AaavePool.sol';
import {WMatic} from './interfaces/WMatic.sol';
import {IAToken} from './interfaces/IAToken.sol';
import {YieldOffseterFactory} from './YieldOffseterFactory.sol';
import {SwappingLogic} from './libraries/SwappingLogic.sol';

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

    /// interface to the aWMATIC token
    IAToken public immutable aWMatic;

    /// amount of WMATIC held by user in the YieldOffseter
    /// @dev TODO could be turned into a mapping to allow multiple assets to be deposited
    uint256 public balance;

    /// amount of WMATIC supplied to the Aave pool
    /// @dev TODO could be turned into a mapping to allow multiple assets to be invested
    uint256 public invested;

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

    /// @notice Emitted when a user supplies MATIC to the Aave pool
    /// @param guy Address of the supplier / investor
    /// @param amount Amount of MATIC supplied
    event Invest(address indexed guy, uint256 amount);

    /// @notice Emitted when a user offsets their yield
    /// @param guy Address of the yield offseter
    /// @param amount Amount of MATIC offset
    event Offset(address indexed guy, uint256 amount);

    /// @notice Emitted when a user withdraws MATIC from Aave pool into the YieldOffseterVault
    /// @param guy Address of the withdrawer
    /// @param amount Amount of MATIC withdrawn
    event Withdraw(address indexed guy, uint256 amount);

    /// @notice Emitted when a user withdraws MATIC from the YieldOffseterVault
    /// @param guy Address of the withdrawer
    /// @param amount Amount of MATIC withdrawn
    event Withdraw2(address indexed guy, uint256 amount);

    // ============================================
    // ================ Constructor ===============
    // ============================================

    /// @dev TODO this is not supposed to be deployable by anyone but the YieldOffseterFactory
    constructor(address aavePoolAddress, address wmaticAddress) {
        yieldOffseterFactory = YieldOffseterFactory(msg.sender);
        aavePool = AavePool(aavePoolAddress);
        wMatic = WMatic(wmaticAddress);
        aWMatic = IAToken(aavePool.getReserveData(wmaticAddress).aTokenAddress);
    }

    // ============================================
    // =============== Public funcs ===============
    // ============================================

    /// @notice Send an amount of MATIC, that gets stored as WMATIC in this vault
    /// @dev TODO I'm keeping this MATIC native deposits because 1. it won't matter if we go multi-asset 2. Toucan offseting can only be done on Polygon for now
    function deposit() public payable onlyVaultOwner {
        balance += msg.value;
        emit Deposit(msg.sender, msg.value);
        wMatic.deposit{value: msg.value}();
    }

    /// @notice Supplies the Aave pool with an amount of deposited WMATIC
    /// @param amount Amount to be supplied
    function supply(uint256 amount) public onlyVaultOwner {
        require(balance >= amount, 'not enough deposited');
        balance -= amount;
        invested += amount;
        emit Invest(msg.sender, amount);
        bool approved = wMatic.approve(address(aavePool), amount);
        require(approved, 'approve failed');
        aavePool.supply(address(wMatic), amount, address(this), 0);
    }

    /// @notice Calculates the amount of yield earned by the caller up until this point
    /// @return yield Amount of WMATIC extra of the amount supplied to Aave
    function checkYield() public view onlyVaultOwner returns (uint256 yield) {
        require(invested > 0, 'nothing invested');
        uint256 aTokenBalance = aWMatic.balanceOf(address(this));
        // we are using SafeMath her because there was a sporadic underflow issue in testing
        yield = SafeMath.sub(aTokenBalance, invested);
    }

    /// @notice Calculates how much TCO2 your current yield could offset
    /// @return offsetable Amount of TCO2 that could be offset by the current yield
    function calculateOffsetable() public view onlyVaultOwner returns (uint256 offsetable) {
        uint256 yield = checkYield();
        require(yield > 0, 'no yield');
        (, uint256[] memory amounts) = SwappingLogic.calculateSwap(yield, address(wMatic));
        offsetable = amounts[amounts.length - 1];
    }

    /// @notice Withdraws the earned yield from the Aave pool & uses it to offset CO2 emissions through the OffsetHelper
    function offsetYield() public onlyVaultOwner {}

    /// @notice Withdraws the supplied WMATIC from the AavePool into the YieldOffseter
    /// @param amount Amount to be withdrawn
    function withdraw(uint256 amount) public onlyVaultOwner {}

    /// @notice Withdraws the deposited WMATIC from the YieldOffseter
    /// @param amount Amount to be withdrawn
    function withdraw2(uint256 amount) public onlyVaultOwner {}
}
