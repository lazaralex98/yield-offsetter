import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { formatEther, getAddress, parseEther } from 'ethers/lib/utils';
import hre, { ethers } from 'hardhat';
import { YieldOffseterFactory } from '../typechain-types';

const AAVE_POOL = getAddress('0x794a61358D6845594F94dc1DB02A252b5b4814aD');
const WMATIC = getAddress('0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270');

describe('YieldOffseterFactory', function () {
  let addrs: SignerWithAddress[];
  let factory: YieldOffseterFactory;

  beforeEach(async function () {
    addrs = await ethers.getSigners();

    const Factory = await hre.ethers.getContractFactory('YieldOffseterFactory');
    factory = await Factory.connect(addrs[0]).deploy(AAVE_POOL, WMATIC);
    await factory.deployed();
  });

  it('should emit a "VaultCreated" event', async function () {
    await expect(factory.connect(addrs[0]).createVault()).to.emit(factory, 'VaultCreated');
  });

  it(`it should have addrs[0] emited as owner in the 'VaultCreated' event`, async function () {
    const tx = await factory.connect(addrs[0]).createVault();
    const receipt = await tx.wait();
    const event = receipt.events?.find((e) => e.event === 'VaultCreated');
    expect(event?.args?._owner).to.equal(addrs[0].address);
  });

  it('should be able to get & interact with the vault', async function () {
    await factory.connect(addrs[0]).createVault();
    const vaultAddress = await factory.getVault(addrs[0].address);
    const vaultContract = await ethers.getContractAt('YieldOffseterVault', vaultAddress, addrs[0]);
    expect(await vaultContract.aavePool()).to.equal(AAVE_POOL);
    expect(await vaultContract.wMatic()).to.equal(WMATIC);
  });

  it('should fail to create a second vault', async function () {
    await factory.connect(addrs[0]).createVault();
    await expect(factory.connect(addrs[0]).createVault()).to.be.revertedWith(
      'vault already exists'
    );
  });
});