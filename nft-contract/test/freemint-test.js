// const { Contract } = require("@ethersproject/contracts");
// const { SignerWithAddress } = require("@nomiclabs/hardhat-ethers/signers");
const { ethers } = require("hardhat");
const { signWhitelist, signGiftlist } = require("../scripts/signList");
// const { expectRevert } = require("@openzeppelin/test-helpers");
const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");
const { expect } = require("chai");

describe("FreeMint-EIP712-ONE", function () {
  let contract;
  let mintingKey;
  let whitelistKey;
  let maliciousKey;

  beforeEach(async function () {
    // const accounts = await ethers.getSigners();
    mintingKey = getAccount();
    whitelistKey = getAccount();
    maliciousKey = getBurnAccount();

    salesAddress = getEnvVariable("SALES_CONTRACT_ADDRESS");
    console.log("Contract = " + salesAddress);
    contract = await getContract(salesAddress, "Crowdsale", getAccount(), hre);
    await contract.setSigningKey(whitelistKey.address);
    await contract.setOpening(true);
  });

  it("Should allow gift if a valid signature is sent", async function () {
    // await contract.setSigningKey(whitelistKey.address);
    // await contract.setOpening(true);
    let { chainId } = await ethers.provider.getNetwork();
    const nonce = await contract.getUserNonce(whitelistKey.address);
    let current = await contract.current();
    console.log("nonce = " + nonce + " current = " + current);

    const sig = await signGiftlist("SONNY-BOOT", chainId, contract.address, whitelistKey, mintingKey.address, nonce);
    // const sig = "0xd67be67b8fe09b470bf62e89b12a82600d5d6219efc1fd8c067cd2c6f330741c41183fdf16e6db33c4421bbe679fe3c59f5ed0d387b4b1c49e0b49f4f52215921b";
    console.log("signature = " + sig);
    await contract.mint(2, sig, {
      gasLimit: 3_000_000,
    });
    expect((await contract.current()).toNumber()).to.be.equal(current.add(2).toNumber());
  });

  it("Should not allow gift  if a different signature is sent", async function () {
    let current = await contract.current();
    let { chainId } = await ethers.provider.getNetwork();
    const sig = await signGiftlist("SONNY-BOOT", chainId, contract.address, whitelistKey, mintingKey.address, 0);
    try {
      await contract.mint(1, sig, {
        gasLimit: 3_000_000,
      });
    } catch (e) {
      console.log("msg:" + e.message);
    }
    expect(await contract.current()).to.be.not.equal(current + 1);
  });
});
