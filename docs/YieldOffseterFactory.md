# YieldOffseterFactory



> YieldOffseterFactory





## Methods

### createVault

```solidity
function createVault() external nonpayable returns (address)
```

Creates a YieldOffseterVault for the caller




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### getVault

```solidity
function getVault(address _guy) external view returns (address)
```

Returns the YieldOffseterVault for `_guy`



#### Parameters

| Name | Type | Description |
|---|---|---|
| _guy | address | Address of the vault owner |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | Address of the YieldOffseterVault that `_guy` owns |




