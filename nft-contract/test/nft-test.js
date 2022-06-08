const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");

describe("NFTERC721-MINT", function () {
  this.timeout(60000000000);
  it("NFTERC721A-mintTo-1", async function () {
    //setTimeout(done, 100000);
    const nft = getEnvVariable("NFTA_CONTRACT_ADDRESS");
    const cnft = await getContract(nft, "NFTERC721A", getAccount(), hre);
    console.log("ERC721A = " + cnft.address);
    let supported = await cnft.supportsInterface("0x80ac58cd", { gasLimit: 2000000 });
    expect(supported).to.be.true;
  });
});

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
