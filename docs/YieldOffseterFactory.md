# YieldOffseterFactory



> YieldOffseterFactory





## Methods

### aavePool

```solidity
function aavePool() external view returns (contract AavePool)
```

interface to the Aave pool




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract AavePool | undefined |

### createVault

```solidity
function createVault() external nonpayable returns (address)
```

Creates a YieldOffseterVault for the caller




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | Address of the newly created YieldOffseterVault |

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

### wMatic

```solidity
function wMatic() external view returns (contract WMatic)
```

interface to the WMATIC token




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract WMatic | undefined |



## Events

### VaultCreated

```solidity
event VaultCreated(address indexed _owner, address indexed _vault)
```

Emitted when a new YieldOffseterVault is created



#### Parameters

| Name | Type | Description |
|---|---|---|
| _owner `indexed` | address | Owner of the YieldOffseterVault |
| _vault `indexed` | address | Address of the YieldOffseterVault |



