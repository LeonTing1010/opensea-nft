const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getContract, getEnvVariable, getAccount } = require("./helpers");

describe("NFT", function () {
  this.timeout(60000000000);
  it("Should burn all nft", async function () {
    //setTimeout(done, 100000);
    const GasLimit = 1_000_000;
    const nft = getEnvVariable("NFT_CONTRACT_ADDRESS");
    console.log("Contract = " + nft);
    const cnft = await getContract(nft, "NFTERC721", getAccount(), hre);

    for (var i = 6077; i <= 10800; i++) {
      address = "0x0000000000000000000000000000000000000000";
      try {
        address = await cnft.ownerOf(i);
        console.log(i, address);
      } catch (error) {
        console.log(i);
      }
      expect(address).to.be.equal("0x0000000000000000000000000000000000000000");
    }
  });
});
