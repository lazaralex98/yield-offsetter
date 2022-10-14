// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

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
}
