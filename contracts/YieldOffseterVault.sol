// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {SafeMath} from '@openzeppelin/contracts/utils/math/SafeMath.sol';

import {AavePool} from './interfaces/AaavePool.sol';
import {WMatic} from './interfaces/WMatic.sol';
import {IAToken} from './interfaces/IAToken.sol';
import {YieldOffseterFactory} from './YieldOffseterFactory.sol';
import {SwappingLogic} from './libraries/SwappingLogic.sol';
import {Errors} from './libraries/Errors.sol';
import {RetirementLogic} from './libraries/RetirementLogic.sol';

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
        require(
            address(this) == yieldOffseterFactory.getVault(msg.sender),
            Errors.V_NOT_VAULT_OWNER
        );
        require(
            msg.sender == yieldOffseterFactory.getVaultOwner(address(this)),
            Errors.V_NOT_VAULT_OWNER
        );
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
    event Offset(address indexed guy, uint256 amount, uint256[] retirementEventIds);

    /// @notice Emitted when a user withdraws MATIC from Aave pool into the YieldOffseterVault
    /// @param guy Address of the withdrawer
    /// @param amount Amount of MATIC withdrawn
    event WithdrawFromAave(address indexed guy, uint256 amount);

    /// @notice Emitted when a user withdraws MATIC from the YieldOffseterVault
    /// @param guy Address of the withdrawer
    /// @param amount Amount of MATIC withdrawn
    event WithdrawFromVault(address indexed guy, uint256 amount);

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
        require(balance >= amount, Errors.V_NOT_ENOUGH_DEPOSITED);
        balance -= amount;
        invested += amount;
        emit Invest(msg.sender, amount);
        bool approved = wMatic.approve(address(aavePool), amount);
        require(approved, Errors.G_APPROVAL_FAILED);
        aavePool.supply(address(wMatic), amount, address(this), 0);
    }

    /// @notice Gets the amount of aWMATIC tokens that the caller has i.e. how much he invested + how much yield he has
    /// @return Amount of aWMATIC tokens
    function getATokenBalance() public view onlyVaultOwner returns (uint256) {
        return aWMatic.balanceOf(address(this));
    }

    /// @notice Calculates the amount of yield earned by the caller up until this point
    /// @param amount Amount of aWMATIC tokens the caller holds within the vault
    /// @return yield Amount of WMATIC extra of the amount supplied to Aave
    function getYield(uint256 amount) public view onlyVaultOwner returns (uint256 yield) {
        // we are using SafeMath here because there was a sporadic underflow issue in testing
        yield = SafeMath.sub(amount, invested);
    }

    /// @notice Calculates how much TCO2 your current yield could offset
    /// @param yield Amount of aWMATIC tokens the caller wants to use to offset
    /// @return offsetable Amount of TCO2 that could be offset by the current yield
    function getOffsetable(uint256 yield) public view onlyVaultOwner returns (uint256 offsetable) {
        if (yield == 0) {
            return 0;
        }
        (, uint256[] memory amounts) = SwappingLogic.calculateSwap(yield, address(wMatic));
        offsetable = amounts[amounts.length - 1];
    }

    /// @notice Withdraws the earned yield from the Aave pool & uses it to offset CO2 emissions
    /// @param amount Amount of aWMATIC tokens the caller wants to use to offset
    /// @return retirementEventIds Array of IDs of the retirement events that were triggered
    function offsetYield(uint256 amount)
        external
        onlyVaultOwner
        returns (uint256[] memory retirementEventIds)
    {
        require(amount > 0, Errors.G_AMOUNT_ZERO);
        require(amount <= getYield(getATokenBalance()), Errors.V_NOT_ENOUGH_YIELD);

        aavePool.withdraw(address(wMatic), amount, address(this));
        uint256 nctBalance = SwappingLogic.swapToCarbon(amount, address(wMatic));
        retirementEventIds = RetirementLogic.redeemAndRetire(nctBalance);

        emit Offset(msg.sender, nctBalance, retirementEventIds);
    }

    /// @notice Withdraws the supplied WMATIC from the AavePool into the YieldOffseterVault
    /// @param amount Amount to be withdrawn
    function withdrawFromAave(uint256 amount) public onlyVaultOwner {
        require(amount > 0, Errors.G_AMOUNT_ZERO);
        require(amount <= invested, Errors.V_NOT_ENOUGH_INVESTED);
        invested -= amount;
        balance += amount;
        emit WithdrawFromAave(msg.sender, amount);
        aavePool.withdraw(address(wMatic), amount, address(this));
    }

    /// @notice Withdraws the deposited MATIC from the YieldOffseter
    /// @param amount Amount to be withdrawn
    function withdrawFromVault(uint256 amount) public onlyVaultOwner {
        require(amount > 0, Errors.G_AMOUNT_ZERO);
        require(amount <= balance, Errors.V_NOT_ENOUGH_BALANCE);
        balance -= amount;
        address owner = yieldOffseterFactory.getVaultOwner(address(this));
        emit WithdrawFromVault(owner, amount);
        wMatic.withdraw(amount);
        payable(owner).transfer(amount);
    }

    receive() external payable {}
}
