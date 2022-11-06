import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { formatEther, parseEther } from 'ethers/lib/utils';
import hre, { ethers } from 'hardhat';
import chalk from 'chalk';

import { Errors, YieldOffseterFactory, YieldOffseterVault } from '../typechain-types';
import { constants, funcs } from '../utils';

const { AAVE_POOL, WMATIC, ONE_ETHER } = constants;

describe('End-to-end testing of user flow on Mumbai network', function () {
  let addrs: SignerWithAddress[];
  let factory: YieldOffseterFactory;
  let vault: YieldOffseterVault;
  let errors: Errors;

  before(async function () {
    if (hre.network.name !== 'mumbai') {
      this.skip();
    }

    const Errors = await hre.ethers.getContractFactory('Errors');
    errors = await Errors.deploy();
    await errors.deployed();

    addrs = await ethers.getSigners();

    const SwappingLogicFactory = await hre.ethers.getContractFactory('SwappingLogic');
    const swappingLogic = await SwappingLogicFactory.deploy();
    await swappingLogic.deployed();

    const RetirementLogicFactory = await hre.ethers.getContractFactory('RetirementLogic');
    const retirementLogic = await RetirementLogicFactory.deploy();
    await retirementLogic.deployed();

    const Factory = await hre.ethers.getContractFactory('YieldOffseterFactory', {
      libraries: {
        SwappingLogic: swappingLogic.address,
        RetirementLogic: retirementLogic.address,
      },
    });
    factory = await Factory.connect(addrs[0]).deploy(AAVE_POOL, WMATIC);
    await factory.deployed();

    await factory.connect(addrs[0]).createVault();
    const vaultAddress = await factory.getVault(addrs[0].address);
    vault = await ethers.getContractAt('YieldOffseterVault', vaultAddress, addrs[0]);
  });

  it('addrs[0] deposits 0.1 MATIC in vault', async function () {
    await vault.connect(addrs[0]).deposit({ value: ONE_ETHER.div(10) });
    expect(formatEther(await vault.balance())).to.equal(
      formatEther(ONE_ETHER.div(10)),
      'Balance should be 0.1 WMATIC'
    );
  });

  it('addrs[0] supplies 0.1 WMATIC in AAVE', async function () {
    await vault.connect(addrs[0]).supply(ONE_ETHER.div(10));
    expect(formatEther(await vault.balance())).to.equal(
      formatEther(parseEther('0.0')),
      'Balance should be 0.0 WMATIC'
    );
    expect(formatEther(await vault.invested())).to.equal(
      formatEther(ONE_ETHER.div(10)),
      'Invested should be 0.1 WMATIC'
    );
  });

  it('should have some yield', async function () {
    await funcs.mineBlocks(hre, 1000 * 10 ** 5, 10);

    const offsetable = await vault
      .connect(addrs[0])
      .getOffsetable(await vault.getYield(await vault.getATokenBalance()));
    expect(offsetable).to.be.gt(parseEther('0.0'), 'Offsetable should be > 0.0');

    console.log(chalk.green(`Offsetable: ${formatEther(offsetable)}`));
  });

  it('addrs[1] should fail to interact with vault', async function () {
    await expect(vault.connect(addrs[1]).getATokenBalance()).to.be.revertedWith(
      await errors.V_NOT_VAULT_OWNER()
    );
    await expect(vault.connect(addrs[1]).getYield(ONE_ETHER)).to.be.revertedWith(
      await errors.V_NOT_VAULT_OWNER()
    );
    await expect(vault.connect(addrs[1]).getOffsetable(ONE_ETHER)).to.be.revertedWith(
      await errors.V_NOT_VAULT_OWNER()
    );
    await expect(vault.connect(addrs[1]).offsetYield(ONE_ETHER)).to.be.revertedWith(
      await errors.V_NOT_VAULT_OWNER()
    );
  });

  it('addrs[0] offsets half of the yield', async function () {
    const aTokenBalance = await vault.getATokenBalance();
    const yieldAmount = await vault.getYield(aTokenBalance);
    await vault.connect(addrs[0]).offsetYield(yieldAmount.div(2));

    expect(await vault.getATokenBalance()).to.lt(aTokenBalance, 'aTokenBalance should be less');
    expect(await vault.getYield(await vault.getATokenBalance())).to.lt(
      yieldAmount,
      'yieldAmount should be less'
    );
  });

  it('addrs[0] deposits & supplies more WMATIC in AAVE', async function () {
    await vault.connect(addrs[0]).deposit({ value: ONE_ETHER.div(10) });
    expect(formatEther(await vault.balance())).to.equal(
      formatEther(ONE_ETHER.div(10)),
      'Balance should be 0.1 WMATIC'
    );

    await vault.connect(addrs[0]).supply(ONE_ETHER.div(10));
    expect(formatEther(await vault.balance())).to.equal(
      formatEther(parseEther('0.0')),
      'Balance should be 0.0 WMATIC'
    );
    expect(formatEther(await vault.invested())).to.equal(
      formatEther(ONE_ETHER.div(5)),
      'Invested should be 0.2 WMATIC'
    );
  });

  it('should wait a few more blocks to generate more yield', async function () {
    await funcs.mineBlocks(hre, 1000 * 10 ** 5, 10);

    const offsetable = await vault
      .connect(addrs[0])
      .getOffsetable(await vault.getYield(await vault.getATokenBalance()));
    expect(offsetable).to.be.gt(parseEther('0.0'), 'Offsetable should be > 0.0');

    console.log(chalk.green(`Offsetable: ${formatEther(offsetable)}`));
  });

  it('should withdraw all of his invested funds, but still have yield left', async function () {
    await vault.connect(addrs[0]).withdrawFromAave(await vault.invested());
    await vault.connect(addrs[0]).withdrawFromVault(await vault.balance());

    expect(formatEther(await vault.invested())).to.equal('0.0', 'Invested should be 0.0 WMATIC');
    expect(formatEther(await vault.balance())).to.equal('0.0', 'Balance should be 0.0 WMATIC');

    const yieldAmount = await vault.connect(addrs[0]).getYield(await vault.getATokenBalance());
    expect(yieldAmount).to.be.gt(parseEther('0.0'), 'Yield should be > 0.0');
    console.log(chalk.blue(`Yield: ${formatEther(yieldAmount)}`));

    const offsetable = await vault.connect(addrs[0]).getOffsetable(yieldAmount);
    expect(offsetable).to.be.gt(parseEther('0.0'), 'Offsetable should be > 0.0');
    console.log(chalk.green(`Offsetable: ${formatEther(offsetable)}`));
  });

  it('addrs[0] should offset the remaining yield', async function () {
    const yieldAmount = await vault.connect(addrs[0]).getYield(await vault.getATokenBalance());
    await vault.connect(addrs[0]).offsetYield(yieldAmount);

    expect(await vault.getATokenBalance()).to.be.lt(
      ONE_ETHER,
      'aTokenBalance should only have trace amounts'
    );
    expect(await vault.getYield(await vault.getATokenBalance())).to.be.lt(
      ONE_ETHER,
      'yieldAmount should only have trace amounts'
    );
  });
});
