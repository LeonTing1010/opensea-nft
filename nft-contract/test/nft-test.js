// const { expect } = require("chai");
// const { ethers } = require("hardhat");
// const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");
//
// describe("NFTERC721-MINT", function () {
//   this.timeout(60000000000);
//   it("NFTERC721A-mintTo-1", async function () {
//     //setTimeout(done, 100000);
//     const nft = getEnvVariable("NFTA_CONTRACT_ADDRESS");
//     const cnft = await getContract(nft, "NFTERC721A", getAccount(), hre);
//     gPrice = await getProvider().getGasPrice();
//     console.log("ERC721A = " + nft + " gasPrice = " + gPrice);
//     try {
//       mintTx = await cnft.mintTo("0x7e76e2Dc706DA155C30cA5c1E2c4582B8bEc786E", { gasLimit: 2000000 });
//       await mintTx.wait();
//     } catch (error) {
//       console.log(error.message);
//     }
//   });
//   it("NFTERC721-mintTo-1", async function () {
//     //setTimeout(done, 100000);
//     const nft = getEnvVariable("NFT_CONTRACT_ADDRESS");
//     const cnft = await getContract(nft, "NFTERC721", getAccount(), hre);
//     gPrice = await getProvider().getGasPrice();
//     console.log("ERC721 = " + nft + " gasPrice = " + gPrice);
//     try {
//       mintTx = await cnft.mintTo("0x7e76e2Dc706DA155C30cA5c1E2c4582B8bEc786E", { gasLimit: 2000000 });
//       await mintTx.wait();
//     } catch (error) {
//       console.log(error.message);
//     }
//   });
// });
// describe("NFTERC721A-GIFT", function () {
//   this.timeout(60000000000);
//   it("gift-100-2", async function () {
//     //setTimeout(done, 100000);
//     gPrice = await getProvider().getGasPrice();
//     const nft = getEnvVariable("NFTA_CONTRACT_ADDRESS");
//     console.log("Contract = " + nft + " GasPrice = " + gPrice);
//     const cnft = await getContract(nft, "NFTERC721A", getAccount(), hre);
//     const lucky = [];
//     while (lucky.length < 100) {
//       lucky.push("0xC42d0b585855Bc74bd15691553f25B75251F2E79");
//     }
//     console.log("array = " + lucky.length);
//     try {
//       mintTx = await cnft.gift(lucky, 2, { gasLimit: 21000000 });
//       await mintTx.wait();
//     } catch (error) {
//       console.log(error.message);
//     }
//   });
//   it("gift-200-1", async function () {
//     //setTimeout(done, 100000);
//     gPrice = await getProvider().getGasPrice();
//     const nft = getEnvVariable("NFTA_CONTRACT_ADDRESS");
//     console.log("Contract = " + nft + " GasPrice = " + gPrice);
//     const cnft = await getContract(nft, "NFTERC721A", getAccount(), hre);
//     const lucky = [];
//     while (lucky.length < 200) {
//       lucky.push("0xC42d0b585855Bc74bd15691553f25B75251F2E79");
//     }
//     console.log("array = " + lucky.length);
//     try {
//       mintTx = await cnft.gift(lucky, 1, { gasLimit: 21000000 });
//       await mintTx.wait();
//     } catch (error) {
//       console.log(error.message);
//     }
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
