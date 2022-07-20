// const { Contract } = require("@ethersproject/contracts");
// const { SignerWithAddress } = require("@nomiclabs/hardhat-ethers/signers");
const { ethers } = require("hardhat");
// const { signWhitelist, signGiftlist } = require("../scripts/signList");
// const { expectRevert } = require("@openzeppelin/test-helpers");
const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");
const { expect } = require("chai");

describe("Gift", function () {
  let contract;
  let transfer;
  let salesAddress;
  let nft;

  beforeEach(async function () {
    // const accounts = await ethers.getSigners();
    transfer = getBurnAccount();
    nft = await getContract(getEnvVariable("NFTA_CONTRACT_ADDRESS"), "NFTERC721A", getAccount(), hre);
    // await nft.setIsProxyActive(true, {
    //   gasLimit: 5_000_000,
    // });

    // await nft.grantRole(nft.MINER_ROLE(), transfer.getAddress(), {
    //   gasLimit: 5_000_000,
    // });
    salesAddress = getEnvVariable("SALES_CONTRACT_ADDRESS");
    console.log("Contract = " + salesAddress);
    // await nft.setProxyAddress(transfer.getAddress());

    // await nft.setProxyAddress(salesAddress);
    contract = await getContract(salesAddress, "Crowdsale", getAccount(), hre);
    await contract.setOpening(true, {
      gasLimit: 5_000_000,
    });
    let current = await contract.current();
    console.log("Current = " + current);
    // await contract.transferById(1, ["0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa", "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa"], [3, 5], {
    //   gasLimit: 3_000_000,
    // });
  });

  // it("Transfer-100", async function () {
  //   var balance = await nft.balanceOf(getAccount().getAddress());
  //   console.log("Balance=> " + (await getAccount().getAddress()) + "=" + balance);
  //   // await nft.transferFrom(getAccount().getAddress(), salesAddress, 1, {
  //   //   gasLimit: 20_000_000,
  //   // });
  //   await contract.transferById(["0x0cbf8cf04894b8ec4c390e6c577637b8e5ea1eda"], [5], {
  //     gasLimit: 3_000_000,
  //   });
  //   console.log("TotalMinted = " + (await contract.totalMinted()));
  //   balance = await nft.balanceOf("0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda");
  //   console.log("Balance=> 0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda=" + balance);
  //   expect(balance.toNumber()).to.be.equal(5);
  // });
  // it("Transfer-owner-2", async function () {
  //   var balance = await nft.balanceOf(getAccount().getAddress());
  //   console.log("Balance=> " + (await getAccount().getAddress()) + "=" + balance);
  //   console.log("Owner  => " + (await contract.owner()));
  //   console.log("NFT  => " + (await contract.token()));
  //   // console.log("msgSender  => " + (await nft.getMsgSender()));
  //   // await nft.transferFrom(getAccount().getAddress(), "0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda", 1, {
  //   //   gasLimit: 3_000_000,
  //   // });
  //   // balance = await nft.balanceOf("0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda");
  //   // console.log("Balance=> 0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda=" + balance);
  //   const rArray = ["0x0cbf8cf04894b8ec4c390e6c577637b8e5ea1eda"];
  //   // const rArray = ["0x0cbf8cf04894b8ec4c390e6c577637b8e5ea1eda"];
  //   // await contract.setApprovalForAll(true, {
  //   //   gasLimit: 5_000_000,
  //   // });
  //   const transferTx = await nft.transfer(9, rArray, [2], {
  //     gasLimit: 5_000_000,
  //   });
  //   // // Receive an event when ANY transfer occurs
  //   // contract.on("Transfer", (from, to, tokenId, event) => {
  //   //   console.log(`${from} sent ${tokenId} to ${to}`);
  //   //   // The event object contains the verbatim log data, the
  //   //   // EventFragment and functions to fetch the block,
  //   //   // transaction and receipt and event functions
  //   // });
  //   // console.log("TotalMinted = " + (await contract.totalMinted()));
  //   balance = await nft.balanceOf("0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda");
  //   console.log("Balance=> 0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda=" + balance);
  //   //expect(balance.toNumber()).to.be.equal(100);
  // });
  it("Transfer-burn-2", async function () {
    // await (await getContract(getEnvVariable("NFTA_CONTRACT_ADDRESS"), "NFTERC721A", getBurnAccount(), hre)).setApprovalForAll(salesAddress, true);
    // await (await getContract(getEnvVariable("NFTA_CONTRACT_ADDRESS"), "NFTERC721A", getBurnAccount(), hre)).setApprovalForAll(salesAddress, true);
    var balance = await nft.balanceOf(getBurnAccount().getAddress());
    console.log("Balance=> " + (await getBurnAccount().getAddress()) + "=" + balance);
    console.log("Owner  => " + (await contract.owner()));
    console.log("NFT  => " + (await contract.token()));
    // console.log("msgSender  => " + (await nft.getMsgSender()));
    // await nft.transferFrom(getAccount().getAddress(), "0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda", 1, {
    //   gasLimit: 3_000_000,
    // });
    // balance = await nft.balanceOf("0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda");
    // console.log("Balance=> 0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda=" + balance);
    const rArray = ["0x0cbf8cf04894b8ec4c390e6c577637b8e5ea1eda"];
    // const rArray = ["0x0cbf8cf04894b8ec4c390e6c577637b8e5ea1eda"];
    const burnNFT = await getContract(getEnvVariable("NFTA_CONTRACT_ADDRESS"), "NFTERC721A", getBurnAccount(), hre);
    // await burnContract.setApprovalForTransfer(true, {
    //   gasLimit: 5_000_000,
    // });
    await nft.grantRole(burnNFT.MINER_ROLE(), transfer.getAddress(), {
      gasLimit: 5_000_000,
    });

    const transferTx = await burnNFT.transfer(1, rArray, [2], {
      gasLimit: 5_000_000,
    });
    // // Receive an event when ANY transfer occurs
    // contract.on("Transfer", (from, to, tokenId, event) => {
    //   console.log(`${from} sent ${tokenId} to ${to}`);
    //   // The event object contains the verbatim log data, the
    //   // EventFragment and functions to fetch the block,
    //   // transaction and receipt and event functions
    // });
    // console.log("TotalMinted = " + (await contract.totalMinted()));
    balance = await nft.balanceOf("0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda");
    console.log("Balance=> 0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda=" + balance);
    //expect(balance.toNumber()).to.be.equal(100);
  });
});
