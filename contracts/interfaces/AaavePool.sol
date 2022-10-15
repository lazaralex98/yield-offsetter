// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

interface AavePool {
    /// @notice The `referralCode` is emitted in Supply event and can be for third party referral integrations.
    /// @notice To activate referral feature and obtain a unique referral code, integrators need to submit proposal to Aave Governance.
    /// @dev When supplying, the Pool contract must have `allowance()` to spend funds on behalf of `msg.sender` for at-least `amount` for the `asset` being supplied.
    /// @param asset address of the asset being supplied to the pool.
    /// @param amount amount of asset being supplied.
    /// @param onBehalfOf address that will receive the corresponding aTokens. (only the `onBehalfOf` address will be able to withdraw asset from the pool.)
    /// @param referralCode unique code for 3rd party referral program integration. Use 0 for no referral.
    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    /// @notice Withdraws `amount` of the underlying `asset`, i.e. redeems the underlying token and burns the aTokens.
    /// @dev When withdrawing to another address, `msg.sender` should have aToken that will be burned by Pool.
    /// @param asset address of the underlying asset, not the aToken
    /// @param amount deposited, expressed in wei units. Use type(uint).max to withdraw the entire balance.
    /// @param to that will receive the asset
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external;

    /// @notice Mints reserve income accrued to treasury (as per the reserve factor) for the given list of assets.
    /// @param assets List of assets for which accrued income is minted
    function mintToTreasury(address[] calldata assets) external;

    /// @notice Returns the state and configuration of the reserve.
    /// @dev part of what is returned is the `aTokenAddress` which is the address of the aToken contract for the given `asset`.
    /// @param asset The address of the underlying asset of the reserve
    /// @return The state and configuration data of the reserve
    function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);
}

library DataTypes {
    struct ReserveData {
        //stores the reserve configuration
        ReserveConfigurationMap configuration;
        //the liquidity index. Expressed in ray
        uint128 liquidityIndex;
        //the current supply rate. Expressed in ray
        uint128 currentLiquidityRate;
        //variable borrow index. Expressed in ray
        uint128 variableBorrowIndex;
        //the current variable borrow rate. Expressed in ray
        uint128 currentVariableBorrowRate;
        //the current stable borrow rate. Expressed in ray
        uint128 currentStableBorrowRate;
        //timestamp of last update
        uint40 lastUpdateTimestamp;
        //the id of the reserve. Represents the position in the list of the active reserves
        uint16 id;
        //aToken address
        address aTokenAddress;
        //stableDebtToken address
        address stableDebtTokenAddress;
        //variableDebtToken address
        address variableDebtTokenAddress;
        //address of the interest rate strategy
        address interestRateStrategyAddress;
        //the current treasury balance, scaled
        uint128 accruedToTreasury;
        //the outstanding unbacked aTokens minted through the bridging feature
        uint128 unbacked;
        //the outstanding debt borrowed against this asset in isolation mode
        uint128 isolationModeTotalDebt;
    }

    struct ReserveConfigurationMap {
        //bit 0-15: LTV
        //bit 16-31: Liq. threshold
        //bit 32-47: Liq. bonus
        //bit 48-55: Decimals
        //bit 56: reserve is active
        //bit 57: reserve is frozen
        //bit 58: borrowing is enabled
        //bit 59: stable rate borrowing enabled
        //bit 60: asset is paused
        //bit 61: borrowing in isolation mode is enabled
        //bit 62-63: reserved
        //bit 64-79: reserve factor
        //bit 80-115 borrow cap in whole tokens, borrowCap == 0 => no cap
        //bit 116-151 supply cap in whole tokens, supplyCap == 0 => no cap
        //bit 152-167 liquidation protocol fee
        //bit 168-175 eMode category
        //bit 176-211 unbacked mint cap in whole tokens, unbackedMintCap == 0 => minting disabled
        //bit 212-251 debt ceiling for isolation mode with (ReserveConfiguration::DEBT_CEILING_DECIMALS) decimals
        //bit 252-255 unused

        uint256 data;
    }
}
