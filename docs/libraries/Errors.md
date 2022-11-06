# Errors



> Errors library

Defines the error messages emitted by the different contracts

*Error messages prefix glossary:  - F = YieldOffseterFactory  - V = YieldOffseterVault  - SW = SwappingLogic  - RE = RetirementLogic  - G = General / Global*

## Methods

### F_ALREADY_HAVE_VAULT

```solidity
function F_ALREADY_HAVE_VAULT() external view returns (string)
```

User already has a vault




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### G_AMOUNT_ZERO

```solidity
function G_AMOUNT_ZERO() external view returns (string)
```

Amount provided cannot be 0




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### G_APPROVAL_FAILED

```solidity
function G_APPROVAL_FAILED() external view returns (string)
```

Approval failed




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### G_ARRAYS_NOT_SAME_LENGTH

```solidity
function G_ARRAYS_NOT_SAME_LENGTH() external view returns (string)
```

Arrays do not have the same length




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### R_INSUFFICIENT_NCT

```solidity
function R_INSUFFICIENT_NCT() external view returns (string)
```

User doesn&#39;t have enough NCT to retire




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### V_NOT_ENOUGH_BALANCE

```solidity
function V_NOT_ENOUGH_BALANCE() external view returns (string)
```

User doesn&#39;t have enough balance in the vault to withdraw that much




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### V_NOT_ENOUGH_DEPOSITED

```solidity
function V_NOT_ENOUGH_DEPOSITED() external view returns (string)
```

User has not deposited enough




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### V_NOT_ENOUGH_INVESTED

```solidity
function V_NOT_ENOUGH_INVESTED() external view returns (string)
```

User doesn&#39;t have enough invested to withdraw that much




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### V_NOT_ENOUGH_YIELD

```solidity
function V_NOT_ENOUGH_YIELD() external view returns (string)
```

User doesn&#39;t have enough yield to offset that much




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### V_NOT_VAULT_OWNER

```solidity
function V_NOT_VAULT_OWNER() external view returns (string)
```

User is not the vault owner




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |




