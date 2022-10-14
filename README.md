# YieldOffseter - A simple tool to offset CO2 at no cost to you

## What is YieldOffseter?

The YieldOffseter is a small set of contracts that allow users to invest their capital into AAVE pools, and then use the yield to offset their carbon footprint. This means you can help the environment without spending any money. Your only costs are the gas fees and opportunity cost of your capital.

## How does it work?

You use the YieldOffseterFactory to create a YieldOffseterVault of your own. This vault will be linked to your wallet, and you can deposit and withdraw funds from it.

Note: you can only have one YieldOffseterVault per wallet.

You can deposit your funds into the vault and interact with the vault to supply AAVE pools.

Whenever you feel enough time has passed, you can check on your yield and calculate how much CO2 it would be able to offset.

If you are happy with the results, you use the yield to offset your carbon footprint. Otherwise, you can keep the funds in the vault to continue to accumulate yield or withdraw them to invest in other pools.

Note: The YieldOffseterVault also allows you to withdraw your funds at any time, back into your wallet.

## Resources

- https://docs.aave.com/developers/core-contracts/pool
- https://github.com/aave/aave-v3-core/blob/master/contracts/protocol/pool/Pool.sol
- https://docs.aave.com/developers/deployed-contracts/v3-mainnet/polygon
- https://docs.aave.com/developers/deployed-contracts/v3-testnet-addresses
- https://github.com/lazaralex98/OffsetHelper-1/blob/main/utils/addresses.ts
