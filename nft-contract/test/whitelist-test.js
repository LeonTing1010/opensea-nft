// const { Contract } = require("@ethersproject/contracts");
// const { SignerWithAddress } = require("@nomiclabs/hardhat-ethers/signers");
const { ethers } = require("hardhat");
const { signWhitelist } = require("../scripts/signWhitelist");
// const { expectRevert } = require("@openzeppelin/test-helpers");
const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");
const { expect } = require("chai");

describe("Token", function () {
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
    // console.log("Contract = " + salesAddress);
    contract = await getContract(salesAddress, "Crowdsale", getAccount(), hre);
    // await contract.setWhitelistSigningAddress(whitelistKey.address);
    // await contract.setOpening(true);

    // let nftAddress = getEnvVariable("NFT_CONTRACT_ADDRESS");
    // const nft = await getContract(nftAddress, "NFTERC721A", getAccount(), hre);
    // await nft.grantRole("0xa952726ef2588ad078edf35b066f7c7406e207cb0003bbaba8cb53eba9553e72", contract.address);
    // await contract.setNft(nftAddress);
  });

  it("Should allow minting with whitelist enabled if a valid signature is sent", async function () {
    let { chainId } = await ethers.provider.getNetwork();
    const sig = signWhitelist(chainId, contract.address, whitelistKey, mintingKey.address);
    console.log("Sig = " + (await sig));
    let price = ethers.BigNumber.from("70000000000000000");
    await contract.preMint(1, sig, {
      gasLimit: 3_000_000,
      value: price,
    });
  });

  it("Should not allow minting with whitelist enabled if a different signature is sent", async function () {
    // const contract = await getContract(salesAddress, "Crowdsale", getAccount(), hre);
    let { chainId } = await ethers.provider.getNetwork();
    const sig = signWhitelist(chainId, contract.address, maliciousKey, mintingKey.address);
    let price = ethers.BigNumber.from("70000000000000000");
    await contract.preMint(1, sig, {
      gasLimit: 3_000_000,
      value: price,
    });
  });
});
