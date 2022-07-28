// const { BigNumber } = require("ethers");
// const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");

// describe("Lottery", function () {
//   this.timeout(60000000000);
//   let Lottery;
//   let OLottery;
//   let gas = {
//     gasLimit: 20_000_000,
//   };
//   let lucky = getAccount();
//   let olucky = getBurnAccount();

//   beforeEach(async function () {
//     const WelfareFoctory = await getContract(getEnvVariable("WELFAREFOCTORY_CONTRACT_ADDRESS"), "WelfareFoctory", lucky, hre);
//     console.log("WelfareFoctory=>" + WelfareFoctory.address);
//     const lot = await WelfareFoctory.getLottery(1);
//     console.log("Lottery=>" + lot);
//     console.log("New Lottery=>" + 1);
//     // await WelfareFoctory.newLottery(1, 4);
//     Lottery = await getContract(lot, "Lottery", lucky, hre);
//     console.log("Lottery=>" + Lottery.address);
//     OLottery = Lottery.connect(olucky);
//     //console.log("Lottery=" + Lottery.address);
//     // await Lottery.setBitMask(12, gas);
//     // Lottery.on("BitMaskChanged", (bits) => {
//     //   console.log("BitMaskChanged=" + bits);
//     // });

//     // Ether amount to send
//     let proportion = "0.5";
//     // await Lottery.setProportion(1, ethers.utils.parseEther(proportion), gas);
//     console.log("Proportion of Bonus is " + (await Lottery.getProportion(1)));
//     // Create a transaction object
//     let tx = {
//       to: Lottery.address,
//       // Convert currency unit from ether to wei
//       value: ethers.utils.parseEther("1"),
//       gasLimit: 10287350,
//       gasPrice: 20850635414,
//     };
//     // console.log("Lucky balance= " + ethers.utils.formatEther(await ethers.provider.getBalance(lucky.address)));
//     // // Send a transaction
//     // await lucky.sendTransaction(tx).then((txObj) => {
//     //   //console.log("txHash", txObj.hash);
//     //   // => 0x9c172314a693b94853b49dc057cf1cb8e529f29ce0272f451eea8f5741aa9b58
//     //   // A transaction result can be checked in a etherscan with a transaction hash which can be obtained here.
//     // });
//   });

//   it("lottery", async function () {
//     await Lottery.lottery(gas);
//     await OLottery.lottery(gas);
//     await Lottery.lottery(gas);
//     await OLottery.lottery(gas);
//     Lottery.on("NewEntry", (player, number) => {
//       console.log("NewEntry=" + player + "=>" + number);
//     });
//     // const cr = await lot.wait();

//     // for (const event of cr.events) {
//     //   console.log(JSON.stringify(event));
//     // }
//     console.log("contract balance= " + ethers.utils.formatEther(await ethers.provider.getBalance(Lottery.address)));
//     await Lottery.drawWords();
//     console.log("----Lucky Lotteries----");
//     for (const l of await await Lottery.getLotterisByAddress(lucky.address)) {
//       console.log(BigNumber.from(l.toString()).toHexString());
//     }
//     console.log("lucky= " + (await Lottery.getWiningsByAddress(lucky.address)).toBigInt());
//     console.log("lucky= ", ethers.utils.formatEther(await Lottery.getBonusByAddress(lucky.address)));

//     console.log("----OLucky Lotteries----");
//     for (const l of await await Lottery.getLotterisByAddress(olucky.address)) {
//       console.log(BigNumber.from(l.toString()).toHexString());
//     }
//     console.log("olucky= " + (await Lottery.getWiningsByAddress(olucky.address)).toBigInt());
//     console.log("olucky= ", ethers.utils.formatEther(await Lottery.getBonusByAddress(olucky.address)));

//     console.log("contract left balance= " + ethers.utils.formatEther(await ethers.provider.getBalance(Lottery.address)));
//   });
//   // it("payout", async function () {
//   //   console.log("contract balance= " + ethers.utils.formatEther(await ethers.provider.getBalance(Lottery.address)));
//   //   const wn = BigNumber.from("0xa3195b98ca25888e443ed56fe8f1e5e958ad97099a69fe8ef4502974ead314a9");
//   //   console.log("WiningNumber= " + wn.toHexString());
//   //   await Lottery._payoutBonus(wn, gas);
//   //   console.log("----Lucky Lotteries----");
//   //   for (const l of await await Lottery.getLotterisByAddress(lucky.address)) {
//   //     console.log(BigNumber.from(l.toString()).toHexString());
//   //   }
//   //   console.log("lucky= " + (await Lottery.getWiningsByAddress(lucky.address)).toBigInt());
//   //   console.log("lucky= ", ethers.utils.formatEther(await Lottery.getBonusByAddress(lucky.address)));

//   //   console.log("----OLucky Lotteries----");
//   //   for (const l of await await Lottery.getLotterisByAddress(olucky.address)) {
//   //     console.log(BigNumber.from(l.toString()).toHexString());
//   //   }
//   //   console.log("olucky= " + (await Lottery.getWiningsByAddress(olucky.address)).toBigInt());
//   //   console.log("olucky= ", ethers.utils.formatEther(await Lottery.getBonusByAddress(olucky.address)));

//   //   console.log("contract left balance= " + ethers.utils.formatEther(await ethers.provider.getBalance(Lottery.address)));
//   // });
// });
