import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { formatEther, parseEther } from 'ethers/lib/utils';
import hre, { ethers } from 'hardhat';
import { YieldOffseterFactory, YieldOffseterVault } from '../typechain-types';
import { constants, ABIs } from '../utils';

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

    it('user should have deposits equal to 1.0 WMATIC in vault', async function () {
      await vault.connect(addrs[0]).deposit({ value: ONE_ETHER });
      expect(formatEther(await vault.deposits(addrs[0].address))).to.equal(formatEther(ONE_ETHER));
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
});
