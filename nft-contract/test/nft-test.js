const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");

// describe("NFTERC721-MINER", function () {
//   this.timeout(60000000000);
//   it("mintTo", async function () {
//     //setTimeout(done, 100000);
//     const nft = getEnvVariable("NFT_CONTRACT_ADDRESS");
//     // console.log("Contract = " + nft);
//     const cnft = await getContract(nft, "NFTERC721", getAccount(), hre);
//     // const miner = await getAccount().getAddress();
//     // console.log("Miner = " + miner);
//     remaining = await cnft.remaining();
//     console.log("remaining = " + remaining.toNumber());
//     NONCE = 1425;
//     while (remaining.toNumber() > 0) {
//       // The gas price (in wei)...
//       gPrice = await getProvider().getGasPrice();
//       console.log("remaining = " + remaining.toNumber() + " gasPrice = " + gPrice);
//       if (gPrice > 30000000000) {
//         continue;
//       }
//       try {
//         mintTx = await cnft.mintTo("0x8dedc1d825d082a9e8ff1ec4ea3661d6c6c6e5c1", { gasPrice: gPrice, gasLimit: 3000000, nonce: NONCE });
//         // mintTx = await cnft.mintTo("0x8dedc1d825d082a9e8ff1ec4ea3661d6c6c6e5c1", { gasPrice: 16000000000, gasLimit: 3000000 });
//         // mintTx = await cnft.mintTo("0x8dedc1d825d082a9e8ff1ec4ea3661d6c6c6e5c1", { gasPrice: gPrice, gasLimit: 3000000 });
//         // await mintTx.wait();
//       } catch (error) {
//         console.log(error.message);
//       } finally {
//         NONCE = NONCE + 1;
//       }
//       remaining = await cnft.remaining();
//     }
//     // done();
//   });
// });

// describe("NFTERC721-BURNER", function () {
//   this.timeout(60000000000);
//   it("burn", async function () {
//     //setTimeout(done, 100000);
//     const nft = getEnvVariable("NFT_CONTRACT_ADDRESS");
//     console.log("Contract = " + nft);
//     const cnft = await getContract(nft, "NFTERC721", getBurnAccount(), hre);
//     // const burner = await getBurnAccount().getAddress();
//     balance = await cnft.balanceOf("0x8dedc1d825d082a9e8ff1ec4ea3661d6c6c6e5c1");
//     console.log("Balance = " + balance.toNumber());
//     NONCE = 1580;
//     while (balance.toNumber() > 0) {
//       nftIds = await cnft.ownerTokens("0x8dedc1d825d082a9e8ff1ec4ea3661d6c6c6e5c1");
//       for (i = 0; i < nftIds.length; i++) {
//         // The gas price (in wei)...
//         gPrice = await getProvider().getGasPrice();
//         console.log("Burn = " + nftIds[i] + " Length=" + (nftIds.length - i) + " gasPrice = " + gPrice);
//         if (gPrice > 30000000000) {
//           continue;
//         }
//         try {
//           burnTx = await cnft.burn(nftIds[i], { gasPrice: gPrice, gasLimit: 100000, nonce: NONCE });
//           // burnTx = await cnft.burn(nftIds[i], { gasPrice: gPrice, gasLimit: 100000 });
//           // burnTx = await cnft.burn(nftIds[i], { nonce: NONCE });
//           // burnTx = await cnft.burn(nftIds[i]);
//           // await burnTx.wait();
//         } catch (error) {
//           console.log(error.message);
//         } finally {
//           NONCE = NONCE + 1;
//         }
//       }
//       balance = await cnft.balanceOf("0x8dedc1d825d082a9e8ff1ec4ea3661d6c6c6e5c1");
//       console.log("Balance = " + balance.toNumber());
//     }
//     //done();
//   });
// });

// describe("Transfer", function () {
//   this.timeout(60000000000);
//   it("transfer", async function () {
//     //setTimeout(done, 100000);
//     const burner = getBurnAccount();
//     transactionResponse = await burner.sendTransaction({
//       to: "0x24B2867950Ad08C4e575d168Dc7fB3f1975bBD9d",
//       value: ethers.utils.parseEther("0.57"), // Sends exactly 1.0 ether
//       gasLimit: 21000,
//       nonce: 1699,
//       gasPrice: 21000000000,
//     });
//     console.log(`Transaction Hash: ${transactionResponse.hash}`);
//     //done();
//   });
// });
