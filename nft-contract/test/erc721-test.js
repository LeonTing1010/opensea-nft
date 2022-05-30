// const { Contract } = require("@ethersproject/contracts");
// const { SignerWithAddress } = require("@nomiclabs/hardhat-ethers/signers");
const { ethers } = require("hardhat");
const { signWhitelist, signGiftlist } = require("../scripts/signList");
// const { expectRevert } = require("@openzeppelin/test-helpers");
const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");
const { expect } = require("chai");

describe("ERC721A", function () {
  let contract;

  beforeEach(async function () {
    nfta = getEnvVariable("NFTA_CONTRACT_ADDRESS");
    console.log("Contract = " + nfta);
    contract = await getContract(nfta, "NFTERC721A", getAccount(), hre);
  });

  it("Should complies with ERC721 standards", async function () {
    const support = (await contract.supportsInterface(0x01ffc9a7)) && (await contract.supportsInterface(0x80ac58cd)) && (await contract.supportsInterface(0x5b5e139f));
    console.log("Support = " + support);
    expect(support).to.be.equal(true);
  });
});
