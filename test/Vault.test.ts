import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { formatEther, parseEther } from 'ethers/lib/utils';
import hre, { ethers } from 'hardhat';

import { Errors, YieldOffseterFactory, YieldOffseterVault } from '../typechain-types';
import { ABIs, constants, funcs } from '../utils';

const { WMATIC_ABI } = ABIs;
const { AAVE_POOL, WMATIC, ONE_ETHER } = constants;

describe('YieldOffseterVault', function () {
  let addrs: SignerWithAddress[];
  let factory: YieldOffseterFactory;
  let errors: Errors;

  before(async function () {
    const Errors = await hre.ethers.getContractFactory('Errors');
    errors = await Errors.deploy();
    await errors.deployed();
  });

  beforeEach(async function () {
    addrs = await ethers.getSigners();

    const SwappingLogicFactory = await hre.ethers.getContractFactory('SwappingLogic');
    const swappingLogic = await SwappingLogicFactory.deploy();
    await swappingLogic.deployed();

    const Errors = await hre.ethers.getContractFactory('Errors');
    const errors = await Errors.deploy();
    await errors.deployed();

    const Factory = await hre.ethers.getContractFactory('YieldOffseterFactory', {
      libraries: {
        SwappingLogic: swappingLogic.address,
      },
    });
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
      expect(formatEther(await vault.balance())).to.equal(
        formatEther(ONE_ETHER),
        'Balance should be 1.0 WMATIC'
      );
    });

    it('vault should have 1.0 WMATIC', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      const wmatic = new ethers.Contract(WMATIC, WMATIC_ABI, addrs[0]);
      expect(formatEther(await wmatic.balanceOf(vault.address))).to.equal(
        formatEther(ONE_ETHER),
        'Vault should have 1.0 WMATIC'
      );
    });

    it('vault should have 0.0 MATIC', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      const balance = await ethers.provider.getBalance(vault.address);
      expect(formatEther(balance)).to.equal('0.0', "Vault shouldn't have any MATIC");
    });

    it(`should fail because it's not this user's vault`, async function () {
      await expect(vault.connect(addrs[1]).deposit({ value: ONE_ETHER })).to.be.revertedWith(
        await errors.V_NOT_VAULT_OWNER()
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
      expect(formatEther(await vault.balance())).to.equal(
        '0.0',
        'User should have 0.0 WMATIC balance in vault'
      );
    });

    it('vault should have 0.0 WMATIC', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await vault.connect(addrs[0]).supply(ONE_ETHER);
      const wmatic = new ethers.Contract(WMATIC, WMATIC_ABI, addrs[0]);
      expect(formatEther(await wmatic.balanceOf(vault.address))).to.equal(
        '0.0',
        "Vault shouldn't have any WMATIC"
      );
    });

    it('vault should have 1.0 aWMATIC', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await vault.connect(addrs[0]).supply(ONE_ETHER);
      const aWmatic = await ethers.getContractAt('IAToken', await vault.aWMatic(), addrs[0]);
      expect(formatEther(await aWmatic.balanceOf(vault.address))).to.equal(
        formatEther(ONE_ETHER),
        'Vault should have 1.0 aWMATIC'
      );
    });

    it(`should fail because it's not this user's vault`, async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await expect(vault.connect(addrs[1]).supply(ONE_ETHER)).to.be.revertedWith(
        await errors.V_NOT_VAULT_OWNER()
      );
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
      expect(formatEther(await vault.getYield(await vault.getATokenBalance()))).to.equal(
        '0.0',
        "User shouldn't have any yield"
      );
    });

    it('user should have yield > 0.0 after a certain amount of blocks have been mined', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await vault.connect(addrs[0]).supply(ONE_ETHER);

      await funcs.mineBlocks(hre, 1000, 10);

      const yieldAmount = await vault.connect(addrs[0]).getYield(await vault.getATokenBalance());
      expect(yieldAmount).to.be.gt(parseEther('0.0'), 'User should have yield');
    });

    it('checking yield should fail because user does not own the vault', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await vault.connect(addrs[0]).supply(ONE_ETHER);
      await funcs.mineBlocks(hre, 1000, 10);

      await expect(
        vault.connect(addrs[1]).getYield(await vault.getATokenBalance())
      ).to.be.revertedWith(await errors.V_NOT_VAULT_OWNER());
    });
  });

  describe('Calculate offsetable TCO2', function () {
    let vault: YieldOffseterVault;

    beforeEach(async function () {
      await factory.connect(addrs[0]).createVault();
      const vaultAddress = await factory.getVault(addrs[0].address);
      vault = await ethers.getContractAt('YieldOffseterVault', vaultAddress, addrs[0]);
    });

    it('user should have offsetable > 0.0 after a certain amount of blocks have been mined', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await vault.connect(addrs[0]).supply(ONE_ETHER);

      await funcs.mineBlocks(hre, 1000, 10);

      const offsetable = await vault
        .connect(addrs[0])
        .getOffsetable(await vault.getYield(await vault.getATokenBalance()));
      expect(offsetable).to.be.gt(parseEther('0.0'), 'Offsetable should be > 0.0');
    });

    it('should fail because user has no yield yet', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await vault.connect(addrs[0]).supply(ONE_ETHER);
      const offsetable = await vault
        .connect(addrs[0])
        .getOffsetable(await vault.getYield(await vault.getATokenBalance()));
      expect(offsetable).to.be.eq(parseEther('0.0'), 'Offsetable should be 0.0');
    });

    it('should fail because user does not own the vault', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      await vault.connect(addrs[0]).supply(ONE_ETHER);
      await funcs.mineBlocks(hre, 1000, 10);

      await expect(
        vault.connect(addrs[1]).getOffsetable(await vault.getYield(await vault.getATokenBalance()))
      ).to.be.revertedWith(await errors.V_NOT_VAULT_OWNER());
    });
  });
});
