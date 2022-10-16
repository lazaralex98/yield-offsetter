import { HardhatRuntimeEnvironment } from 'hardhat/types';

/**
 *
 * @param hre HardhatRuntimeEnvironment
 * @param blocks Amount of blocks to mine
 * @param seconds Seconds it takes to mine one block
 */
export const mineBlocks = async (
  hre: HardhatRuntimeEnvironment,
  blocks: number,
  seconds: number
) => {
  const blocksHex = '0x' + blocks.toString(16);
  const secondsHex = '0x' + seconds.toString(16);
  await hre.network.provider.send('hardhat_mine', [blocksHex, secondsHex]);
};
