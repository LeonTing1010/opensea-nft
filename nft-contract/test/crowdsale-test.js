const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getContract, getEnvVariable, getAccount } = require("./helpers");

describe("Crowdsale", function () {
  this.timeout(60000000000);
  let contract;
  let account;

  beforeEach(async function () {
    account = getAccount();
    salesAddress = getEnvVariable("SALES_CONTRACT_ADDRESS");
    console.log("Contract = " + salesAddress);
    contract = await getContract(salesAddress, "Crowdsale", getAccount(), hre);
    await contract.setOpening(false);
    await contract.setMLimit(100);
    let supply = await contract.current();
    console.log("Current = " + supply);
  });
  it("mint-10", async function () {
    //setTimeout(done, 100000);
    const GasLimit = 1_000_000;
    const miner = await account.getAddress();
    let price = ethers.BigNumber.from("1000000000000000");
    await contract.setSalePrice(price);
    let supply = await contract.current();
    const limit = 100;
    mintTx = await contract.mint(limit, { gasLimit: GasLimit, value: price.mul(limit) });
    await mintTx.wait();
    let current = await contract.current();
    console.log(miner, current.toNumber(), limit);
    expect(current.sub(supply)).to.be.eqls(ethers.BigNumber.from(limit));
  });
  it("mint-11", async function () {
    //setTimeout(done, 100000);
    const GasLimit = 1_000_000;
    let price = ethers.BigNumber.from("1000000000000000");
    await contract.setSalePrice(price);
    const limit = 11;
    try {
      mintTx = await contract.mint(limit, { gasLimit: GasLimit, value: price.mul(limit) });
      await mintTx.wait();
    } catch (error) {
      console.log(error.message);
    }
  });
});
