// const { Contract } = require("@ethersproject/contracts");
// const { SignerWithAddress } = require("@nomiclabs/hardhat-ethers/signers");
const { ethers } = require("hardhat");
// const { signWhitelist, signGiftlist } = require("../scripts/signList");
// const { expectRevert } = require("@openzeppelin/test-helpers");
const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");
const { expect } = require("chai");

describe("Gift", function () {
  let contract;
  let mintingKey;

  beforeEach(async function () {
    // const accounts = await ethers.getSigners();
    mintingKey = getAccount();

    salesAddress = getEnvVariable("SALES_CONTRACT_ADDRESS");
    console.log("Contract = " + salesAddress);
    contract = await getContract(salesAddress, "Crowdsale", getAccount(), hre);
    await contract.setOpening(true);
  });

  it("Gift-100", async function () {
    let supply = await contract.current();
    const amount = supply - 100;
    console.log("Gift = " + amount);
    await contract.gift([mintingKey.getAddress()], [amount], {
      gasLimit: 3_000_000,
    });
    let current = await contract.current();
    console.log("Current = " + current);
    expect(current.toNumber()).to.be.equal(supply.add(amount).toNumber());
  });
});
