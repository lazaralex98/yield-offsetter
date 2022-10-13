import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import 'hardhat-contract-sizer';
import '@primitivefi/hardhat-dodoc';
import '@nomiclabs/hardhat-etherscan';

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

const config: HardhatUserConfig = {
  solidity: '0.8.17',
  contractSizer: {
    runOnCompile: true,
  },
  dodoc: {
    runOnCompile: true,
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};

export default config;
