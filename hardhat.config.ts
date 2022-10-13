import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import 'hardhat-contract-sizer';

const config: HardhatUserConfig = {
  solidity: '0.8.17',
  contractSizer: {
    runOnCompile: true,
  },
};

export default config;
