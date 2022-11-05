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
function getVault(address guy) external view returns (address)
```

Returns the YieldOffseterVault for `guy`



#### Parameters

| Name | Type | Description |
|---|---|---|
| guy | address | Address of the vault owner |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | Address of the YieldOffseterVault that `guy` owns |

### getVaultOwner

```solidity
function getVaultOwner(address vault) external view returns (address)
```

Gets the address of the owner of the YieldOffseterVault



#### Parameters

| Name | Type | Description |
|---|---|---|
| vault | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | Address of the owner |

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
event VaultCreated(address indexed owner, address indexed vault)
```

Emitted when a new YieldOffseterVault is created



#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | Owner of the YieldOffseterVault |
| vault `indexed` | address | Address of the YieldOffseterVault |



