# SwappingLogic



> SwappingLogic





## Methods

### NCT

```solidity
function NCT() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### SWAP_ROUTER

```solidity
function SWAP_ROUTER() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### USDC

```solidity
function USDC() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### buildPath

```solidity
function buildPath(address from) external pure returns (address[])
```

Builds the path to be used for swapping `from` to NCT



#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | The token to swap from |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address[] | path The path to be used for swapping |

### calculateSwap

```solidity
function calculateSwap(uint256 amountIn, address from) external view returns (address[] path, uint256[] amounts)
```

Calculates the amount of NCT that will be received from swapping `amountIn` of `from` tokens

*Makes external calls to the swap router*

#### Parameters

| Name | Type | Description |
|---|---|---|
| amountIn | uint256 | The amount of `from` tokens to swap |
| from | address | The token to swap from |

#### Returns

| Name | Type | Description |
|---|---|---|
| path | address[] | The path of tokens to swap through |
| amounts | uint256[] | The amounts of tokens to swap at each path step |




