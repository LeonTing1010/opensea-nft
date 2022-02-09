const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getContract, getEnvVariable, getAccount } = require("./helpers");

describe("Crowdsale", function () {
  //this.timeout(200000);
  it("Should mint all nfts", async function () {
    //setTimeout(done, 100000);
    const GasLimit = 1_000_000;
    const salesAddress = getEnvVariable("SALES_CONTRACT_ADDRESS");
    const contractCrowdsale = await getContract(salesAddress, "Crowdsale", hre);
    const miner = await getAccount().getAddress();
    var limit = await contractCrowdsale.limit(miner);
    console.log("Limit = " + limit)
    let price = ethers.BigNumber.from("10000000000000000")
    //expect(limit).to.equal(0);
    if (limit > 0) {
      mintTx = await contractCrowdsale.mint(limit, { gasLimit: GasLimit, value: price.mul(limit), });
      await mintTx.wait();
    }
    expect(await contractCrowdsale.limit(miner)).to.be.eqls(ethers.BigNumber.from(0));
    var sold = await contractCrowdsale.soldBy(miner);
    console.log("Sold = " + sold)
    const maxTx = await contractCrowdsale.setMaxAmount(ethers.BigNumber.from(5).add(sold));
    await maxTx.wait();
    limit = await contractCrowdsale.limit(miner);
    console.log("Limit = " + limit)
    expect(limit).to.be.eqls(ethers.BigNumber.from(5));
    let amount = 4;
    mintTx = await contractCrowdsale.mint(amount, {
      gasLimit: GasLimit,
      value: price.mul(amount),
    });
    // wait until the transaction is mined
    await mintTx.wait();
    limit = await contractCrowdsale.limit(miner);
    console.log("Limit = " + limit)
    expect(limit).to.be.eqls(ethers.BigNumber.from(1));
    console.log("async done");
  });
});
