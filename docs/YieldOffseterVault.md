# YieldOffseterVault



> YieldOffseterVault





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

### calculateOffsetable

```solidity
function calculateOffsetable() external view returns (uint256)
```

Calculates how much CO2 your current yield could offset




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | Amount of CO2 that could be offset by the current yield |

### checkYield

```solidity
function checkYield() external view returns (uint256)
```

Calculates the amount of yield earned by the caller




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | Amount of WMATIC extra of the supplied amount |

### deposit

```solidity
function deposit(uint256 _amount) external payable
```

Deposit an `amount` of MATIC, to be later supplied to the Aave pool as WMATIC



#### Parameters

| Name | Type | Description |
|---|---|---|
| _amount | uint256 | Amount of tokens to be supplied |

### deposits

```solidity
function deposits(address) external view returns (uint256)
```

amounts of deposited WMATIC by each user into the YieldOffseter

*TODO could be turned into a nested mapping to allow multiple assets to be deposited*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### offsetYield

```solidity
function offsetYield() external nonpayable
```

Withdraws the earned yield from the Aave pool &amp; uses it to offset CO2 emissions through the OffsetHelper




### supply

```solidity
function supply(uint256 _amount) external nonpayable
```

Supplies the Aave pool with an amount of deposited WMATIC



#### Parameters

| Name | Type | Description |
|---|---|---|
| _amount | uint256 | Amount to be supplied |

### wMatic

```solidity
function wMatic() external view returns (contract WMatic)
```

interface to the WMATIC token




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract WMatic | undefined |

### withdraw

```solidity
function withdraw(uint256 _amount) external nonpayable
```

Withdraws the supplied WMATIC from the AavePool into the YieldOffseter



#### Parameters

| Name | Type | Description |
|---|---|---|
| _amount | uint256 | Amount to be withdrawn |

### withdraw2

```solidity
function withdraw2(uint256 _amount) external nonpayable
```

Withdraws the deposited WMATIC from the YieldOffseter



#### Parameters

| Name | Type | Description |
|---|---|---|
| _amount | uint256 | Amount to be withdrawn |

### yieldOffseterFactory

```solidity
function yieldOffseterFactory() external view returns (contract YieldOffseterFactory)
```

interface to the YieldOffseterFactory




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract YieldOffseterFactory | undefined |




