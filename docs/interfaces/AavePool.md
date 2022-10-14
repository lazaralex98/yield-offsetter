# AavePool









## Methods

### mintToTreasury

```solidity
function mintToTreasury(address[] assets) external nonpayable
```

Mints reserve income accrued to treasury (as per the reserve factor) for the given list of assets.



#### Parameters

| Name | Type | Description |
|---|---|---|
| assets | address[] | List of assets for which accrued income is minted |

### supply

```solidity
function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external nonpayable
```

The `referralCode` is emitted in Supply event and can be for third party referral integrations.To activate referral feature and obtain a unique referral code, integrators need to submit proposal to Aave Governance.

*When supplying, the Pool contract must have `allowance()` to spend funds on behalf of `msg.sender` for at-least `amount` for the `asset` being supplied.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| asset | address | address of the asset being supplied to the pool. |
| amount | uint256 | amount of asset being supplied. |
| onBehalfOf | address | address that will receive the corresponding aTokens. (only the `onBehalfOf` address will be able to withdraw asset from the pool.) |
| referralCode | uint16 | unique code for 3rd party referral program integration. Use 0 for no referral. |

### withdraw

```solidity
function withdraw(address asset, uint256 amount, address to) external nonpayable
```

Withdraws `amount` of the underlying `asset`, i.e. redeems the underlying token and burns the aTokens.

*When withdrawing to another address, `msg.sender` should have aToken that will be burned by Pool.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| asset | address | address of the underlying asset, not the aToken |
| amount | uint256 | deposited, expressed in wei units. Use type(uint).max to withdraw the entire balance. |
| to | address | that will receive the asset |




