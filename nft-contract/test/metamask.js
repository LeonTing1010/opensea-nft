// const { getAccount, getContract, getEnvVariable } = require("../scripts/helpers");

// describe("FreeMint-EIP712-1", function () {
//   this.timeout(60000000000);
//   let contract;
//   let mintingKey;
//   let whitelistKey;
//   let util = require("eth-sig-util");

//   beforeEach(async function () {
//     // const accounts = await ethers.getSigners();
//     mintingKey = getAccount();
//     whitelistKey = getAccount();

//     contract = getEnvVariable("SALES_CONTRACT_ADDRESS");
//     console.log("Contract = " + contract);
//     //contract = await getContract(salesAddress, "Crowdsale", getAccount(), hre);
//   });
//   it("Should allow gift if a valid signature is sent", async function () {
//     let { chainId } = await ethers.provider.getNetwork();
//     var privateKeyHex = Buffer.from(getEnvVariable("ACCOUNT_PRIVATE_KEY"), "hex");
//     // console.log("privateKeyHex", privateKeyHex.toString("hex"));
//     //V4签名
//     const typedData = {
//       types: {
//         EIP712Domain: [
//           { name: "name", type: "string" },
//           { name: "version", type: "string" },
//           { name: "chainId", type: "uint256" },
//           { name: "verifyingContract", type: "address" },
//         ],
//         Gift: [{ name: "wallet", type: "address" }],
//       },
//       domain: {
//         name: "SONNY-BOOT",
//         version: "1",
//         chainId: chainId,
//         verifyingContract: contract,
//       },
//       primaryType: "Gift",
//       message: {
//         wallet: whitelistKey.address,
//       },
//     };

//     //V4签名
//     var signature = util.signTypedData_v4(privateKeyHex, { data: typedData });
//     console.log("signature = " + signature);

//     //V4验签
//     const recovered = util.recoverTypedSignature_v4({
//       data: typedData,
//       sig: signature,
//     });
//     console.log("recovered= ", recovered);
//   });
// });
