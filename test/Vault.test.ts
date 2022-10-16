import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { formatEther, parseEther } from 'ethers/lib/utils';
import hre, { ethers } from 'hardhat';

import { YieldOffseterFactory, YieldOffseterVault } from '../typechain-types';
import { ABIs, constants, funcs } from '../utils';

const { WMATIC_ABI } = ABIs;
const { AAVE_POOL, WMATIC, ONE_ETHER } = constants;

describe('YieldOffseterVault', function () {
  let addrs: SignerWithAddress[];
  let factory: YieldOffseterFactory;

  beforeEach(async function () {
    addrs = await ethers.getSigners();

    const Factory = await hre.ethers.getContractFactory('YieldOffseterFactory');
    factory = await Factory.connect(addrs[0]).deploy(AAVE_POOL, WMATIC);
    await factory.deployed();
  });

  describe('Depositing', function () {
    let vault: YieldOffseterVault;

    beforeEach(async function () {
      await factory.connect(addrs[0]).createVault();
      const vaultAddress = await factory.getVault(addrs[0].address);
      vault = await ethers.getContractAt('YieldOffseterVault', vaultAddress, addrs[0]);
    });

    it('user should have balance equal to 1.0 WMATIC in vault', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      expect(formatEther(await vault.balance())).to.equal(formatEther(ONE_ETHER));
    });

    it('vault should have 1.0 WMATIC', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      const wmatic = new ethers.Contract(WMATIC, WMATIC_ABI, addrs[0]);
      expect(formatEther(await wmatic.balanceOf(vault.address))).to.equal(formatEther(ONE_ETHER));
    });

    it('vault should have 0.0 MATIC', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      const balance = await ethers.provider.getBalance(vault.address);
      expect(formatEther(balance)).to.equal('0.0');
    });

    it(`should fail because it's not this user's vault`, async function () {
      await expect(vault.connect(addrs[1]).deposit({ value: ONE_ETHER })).to.be.revertedWith(
        'not your vault'
      );
    });
  });

  describe('Supplying Aave pool', function () {
    let vault: YieldOffseterVault;

    beforeEach(async function () {
      await factory.connect(addrs[0]).createVault();
      const vaultAddress = await factory.getVault(addrs[0].address);
      vault = await ethers.getContractAt('YieldOffseterVault', vaultAddress, addrs[0]);
    });

    it('user should have balance equal to 0.0 WMATIC in vault', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await vault.connect(addrs[0]).supply(ONE_ETHER);
      expect(formatEther(await vault.balance())).to.equal('0.0');
    });

    it('vault should have 0.0 WMATIC', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await vault.connect(addrs[0]).supply(ONE_ETHER);
      const wmatic = new ethers.Contract(WMATIC, WMATIC_ABI, addrs[0]);
      expect(formatEther(await wmatic.balanceOf(vault.address))).to.equal('0.0');
    });

    it('vault should have 1.0 aWMATIC', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await vault.connect(addrs[0]).supply(ONE_ETHER);
      const aWmatic = await ethers.getContractAt('IAToken', await vault.aWMatic(), addrs[0]);
      expect(formatEther(await aWmatic.balanceOf(vault.address))).to.equal(formatEther(ONE_ETHER));
    });

    it(`should fail because it's not this user's vault`, async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await expect(vault.connect(addrs[1]).supply(ONE_ETHER)).to.be.revertedWith('not your vault');
    });
  });

  describe('Check user yield', function () {
    let vault: YieldOffseterVault;

    beforeEach(async function () {
      await factory.connect(addrs[0]).createVault();
      const vaultAddress = await factory.getVault(addrs[0].address);
      vault = await ethers.getContractAt('YieldOffseterVault', vaultAddress, addrs[0]);
    });

    it('user should have yield == 0.0', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await vault.connect(addrs[0]).supply(ONE_ETHER);
      expect(formatEther(await vault.checkYield())).to.equal('0.0');
    });

    it('user should have yield > 0.0 after a certain amount of blocks have been mined', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await vault.connect(addrs[0]).supply(ONE_ETHER);

      await funcs.mineBlocks(hre, 1000, 10);

      const yieldAmount = await vault.connect(addrs[0]).checkYield();
      expect(yieldAmount).to.be.gt(parseEther('0.0'));
    });

    it('checking yield should fail because user has not invested yet', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });

      await expect(vault.connect(addrs[0]).checkYield()).to.be.revertedWith('nothing invested');
    });

    it('checking yield should fail because user does not own the vault', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await vault.connect(addrs[0]).supply(ONE_ETHER);
      await funcs.mineBlocks(hre, 1000, 10);

      await expect(vault.connect(addrs[1]).checkYield()).to.be.revertedWith('not your vault');
    });
  });
});
