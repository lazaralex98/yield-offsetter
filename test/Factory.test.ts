import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import hre, { ethers } from 'hardhat';

import { Errors, YieldOffseterFactory } from '../typechain-types';
import { constants } from '../utils';

const { AAVE_POOL, WMATIC } = constants;

describe('Unit tests for YieldOffseterFactory on Hardhat network', function () {
  let addrs: SignerWithAddress[];
  let factory: YieldOffseterFactory;
  let errors: Errors;

  before(async function () {
    if (hre.network.name !== 'hardhat') {
      this.skip();
    }

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
  });

  it('should emit a "VaultCreated" event', async function () {
    await expect(factory.connect(addrs[0]).createVault()).to.emit(factory, 'VaultCreated');
  });

  it(`it should have addrs[0] emited as owner in the 'VaultCreated' event`, async function () {
    const tx = await factory.connect(addrs[0]).createVault();
    const receipt = await tx.wait();
    const event = receipt.events?.find((e) => e.event === 'VaultCreated');
    expect(event?.args?.owner).to.equal(addrs[0].address);
  });

  it('should be able to get & interact with the vault', async function () {
    await factory.connect(addrs[0]).createVault();
    const vaultAddress = await factory.getVault(addrs[0].address);
    const vaultContract = await ethers.getContractAt('YieldOffseterVault', vaultAddress, addrs[0]);
    expect(await vaultContract.aavePool()).to.equal(AAVE_POOL);
    expect(await vaultContract.wMatic()).to.equal(WMATIC);
  });

  it('should be able to get owner of a vault', async function () {
    await factory.connect(addrs[0]).createVault();
    const vaultAddress = await factory.getVault(addrs[0].address);
    expect(await factory.connect(addrs[1]).getVaultOwner(vaultAddress)).to.equal(addrs[0].address);
  });

  it('should fail to create a second vault', async function () {
    await factory.connect(addrs[0]).createVault();
    await expect(factory.connect(addrs[0]).createVault()).to.be.revertedWith(
      await errors.F_ALREADY_HAVE_VAULT()
    );
  });
});
