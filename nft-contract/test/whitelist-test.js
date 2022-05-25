// const { Contract } = require("@ethersproject/contracts");
// const { SignerWithAddress } = require("@nomiclabs/hardhat-ethers/signers");
const { ethers } = require("hardhat");
const { signWhitelist, signGiftlist } = require("../scripts/signList");
// const { expectRevert } = require("@openzeppelin/test-helpers");
const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");
const { expect } = require("chai");

describe("FreeMint-EIP712-2", function () {
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
    // await contract.setWhitelistSigningAddress(whitelistKey.address);
    // await contract.setOpening(true);

    // let nftAddress = getEnvVariable("NFT_CONTRACT_ADDRESS");
    // const nft = await getContract(nftAddress, "NFTERC721A", getAccount(), hre);
    // await nft.grantRole("0xa952726ef2588ad078edf35b066f7c7406e207cb0003bbaba8cb53eba9553e72", contract.address);
    // await contract.setNft(nftAddress);
  });

  // it("Should allow minting with whitelist enabled if a valid signature is sent", async function () {
  //   let { chainId } = await ethers.provider.getNetwork();
  //   const address = ["0x5cE7Ce18B65e193d0DfF3F9e72B65A67eE84E455", "0x30a9A5cCEBBCd60cd83585b4f84bA0F988ad7D66", "0xbAbd162A3922d693FbF315900098DA46a87BF12D"];
  //   for (var i = 0; i < address.length; i++) {
  //     let signature = await signWhitelist(chainId, contract.address, whitelistKey, address[i]);
  //     console.log("Address = " + address[i] + " Sig = " + signature);
  //   }

  //   // let price = ethers.BigNumber.from("70000000000000000");
  //   // await contract.preMint(1, sig, {
  //   //   gasLimit: 3_000_000,
  //   //   value: price,
  //   // });
  // });

  // it("Should not allow minting with whitelist enabled if a different signature is sent", async function () {
  //   // const contract = await getContract(salesAddress, "Crowdsale", getAccount(), hre);
  //   let { chainId } = await ethers.provider.getNetwork();
  //   const sig = signWhitelist(chainId, contract.address, maliciousKey, mintingKey.address);
  //   let price = ethers.BigNumber.from("70000000000000000");
  //   try {
  //     await contract.preMint(1, sig, {
  //       gasLimit: 3_000_000,
  //       value: price,
  //     });
  //   } catch (e) {
  //     console.log("msg:" + e.message);
  //   }
  // });

  it("Should allow gift if a valid signature is sent", async function () {
    // await contract.setGiftSigningAddress(whitelistKey.address);
    await contract.setOpening(true);
    let { chainId } = await ethers.provider.getNetwork();
    const sig = signGiftlist("SONNY-BOOT", chainId, contract.address, whitelistKey, mintingKey.address);
    console.log("signature = " + (await sig));
    await contract.boot(sig, {
      gasLimit: 3_000_000,
    });
  });

  // it("Should not allow gift  if a different signature is sent", async function () {
  //   // const contract = await getContract(salesAddress, "Crowdsale", getAccount(), hre);
  //   let { chainId } = await ethers.provider.getNetwork();
  //   const sig = signGiftlist(chainId, contract.address, maliciousKey, mintingKey.address);
  //   try {
  //     await contract.gift(1, sig, {
  //       gasLimit: 3_000_000,
  //     });
  //   } catch (e) {
  //     console.log("msg:" + e.message);
  //   }
  // });
});
