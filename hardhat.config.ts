import '@nomicfoundation/hardhat-toolbox';
import 'hardhat-contract-sizer';
import '@primitivefi/hardhat-dodoc';
import '@nomiclabs/hardhat-etherscan';
import '@nomiclabs/hardhat-solhint';
import '@typechain/hardhat';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-waffle';
import '@openzeppelin/hardhat-upgrades';

import { HardhatUserConfig } from 'hardhat/config';

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [];
const POLYGON_ENDPOINT = process.env.POLYGON_ENDPOINT || 'https://matic-mainnet.chainstacklabs.com';
const MUMBAI_ENDPOINT = process.env.MUMBAI_ENDPOINT || 'https://matic-mumbai.chainstacklabs.com';

const config: HardhatUserConfig = {
  defaultNetwork: 'hardhat',
  solidity: {
    version: '0.8.16',
    settings: {
      optimizer: {
        enabled: true,
        runs: 500,
      },
    },
  },
  networks: {
    polygon: {
      url: POLYGON_ENDPOINT,
      accounts: PRIVATE_KEY,
    },
    mumbai: {
      url: MUMBAI_ENDPOINT,
      accounts: PRIVATE_KEY,
    },
    hardhat: {
      forking: {
        url: POLYGON_ENDPOINT,
      },
    },
  },
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
