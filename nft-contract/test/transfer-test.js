// // const { Contract } = require("@ethersproject/contracts");
// // const { SignerWithAddress } = require("@nomiclabs/hardhat-ethers/signers");
// const { ethers } = require("hardhat");
// // const { signWhitelist, signGiftlist } = require("../scripts/signList");
// // const { expectRevert } = require("@openzeppelin/test-helpers");
// const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");
// const { expect } = require("chai");

// describe("Transfer", function () {
//   let contract;
//   let transfer;
//   let salesAddress;
//   let nft;

//   beforeEach(async function () {
//     // const accounts = await ethers.getSigners();
//     transfer = getBurnAccount();
//     nft = await getContract(getEnvVariable("NFTA_CONTRACT_ADDRESS"), "NFTERC721A", getAccount(), hre);
//     // await nft.setIsProxyActive(true, {
//     //   gasLimit: 5_000_000,
//     // });

//     // await nft.grantRole(nft.MINER_ROLE(), transfer.getAddress(), {
//     //   gasLimit: 5_000_000,
//     // });

//     salesAddress = getEnvVariable("SALES_CONTRACT_ADDRESS");
//     console.log("Contract = " + salesAddress);
//     // await nft.setProxyAddress(transfer.getAddress());

//     // await nft.setProxyAddress(salesAddress);
//     contract = await getContract(salesAddress, "Crowdsale", getAccount(), hre);
//     await contract.setOpening(true, {
//       gasLimit: 5_000_000,
//     });
//     // let current = await contract.current();
//     // console.log("Current = " + current);

//     const hasRole = await contract.hasRole(contract.CROWD_ROLE(), transfer.getAddress());
//     if (!hasRole) {
//       await contract.grantRole(contract.CROWD_ROLE(), transfer.getAddress());
//     }
//   });
//   it("Transfer-2", async function () {
//     var balance = await nft.balanceOf(transfer.getAddress());
//     console.log("Balance=> " + (await transfer.getAddress()) + "=" + balance);
//     console.log("Owner  => " + (await contract.owner()));
//     // console.log("NFT  => " + (await contract.token()));
//     // console.log("msgSender  => " + (await nft.getMsgSender()));
//     const rArray = ["0x0cbf8cf04894b8ec4c390e6c577637b8e5ea1eda"];
//     const transferFunc = await getContract(salesAddress, "Crowdsale", transfer, hre);
//     const tr = await transferFunc.transfer(1, rArray, [2], {
//       gasLimit: 5_000_000,
//     });

//     // Receive an event when ANY transfer occurs
//     // contract.on("TransferEvent", (token, sender, tokenId, event) => {
//     //   console.log(token + "=>" + sender + "=>" + tokenId);
//     //   // The event object contains the verbatim log data, the
//     //   // EventFragment and functions to fetch the block,
//     //   // transaction and receipt and event functions
//     // });
//     // console.log("TotalMinted = " + (await contract.totalMinted()));
//     balance = await nft.balanceOf("0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda");
//     console.log("Balance=> 0x0Cbf8cf04894B8EC4c390E6c577637b8e5EA1eda=" + balance);
//     //expect(balance.toNumber()).to.be.equal(100);
//   });
// });
