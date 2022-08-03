const { BigNumber } = require("ethers");
const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");

describe("Lottery", function () {
  this.timeout(60000000000);
  let Lottery;
  let OLottery;
  let lucky;
  let olucky;
  let gas = {
    gasLimit: 5_000_000,
  };

  beforeEach(async function () {
    lucky = getAccount();
    olucky = getBurnAccount();
    Lottery = await getContract(getEnvVariable("LOTTERY_CONTRACT_ADDRESS"), "Lottery", lucky, hre);
    OLottery = await getContract(getEnvVariable("LOTTERY_CONTRACT_ADDRESS"), "Lottery", olucky, hre);
    //console.log("Lottery=" + Lottery.address);
    await Lottery.setBitMask(12, gas);
    Lottery.on("BitMaskChanged", (bits) => {
      console.log("BitMaskChanged=" + bits);
    });

    // Ether amount to send
    let proportion = "0.5";
    await Lottery.setProportion(0, ethers.utils.parseEther(proportion), gas);
    console.log("Proportion of Prize is " + (await Lottery.getProportion(1)));
    // Create a transaction object
    let tx = {
      to: Lottery.address,
      // Convert currency unit from ether to wei
      value: ethers.utils.parseEther(proportion),
    };
    // Send a transaction
    await lucky.sendTransaction(tx).then((txObj) => {
      //console.log("txHash", txObj.hash);
      // => 0x9c172314a693b94853b49dc057cf1cb8e529f29ce0272f451eea8f5741aa9b58
      // A transaction result can be checked in a etherscan with a transaction hash which can be obtained here.
    });
  });

  it("lottery", async function () {
    // await Lottery.lottery(gas);
    // await OLottery.lottery(gas);
    Lottery.on("NewEntry", (player, number) => {
      console.log("NewEntry=" + player + "=>" + number);
    });
    // const cr = await lot.wait();

    // for (const event of cr.events) {
    //   console.log(JSON.stringify(event));
    // }
  });
  it("payout", async function () {
    console.log("contract balance= " + ethers.utils.formatEther(await ethers.provider.getBalance(Lottery.address)));
    const wn = BigNumber.from("0xa3195b98ca25888e443ed56fe8f1e5e958ad97099a69fe8ef4502974ead314a9");
    console.log("WiningNumber= " + wn.toHexString());
    await Lottery._payoutPrize(wn, gas);
    console.log("----Lucky Lotteries----");
    for (const l of await await Lottery.getLotterisByAddress(lucky.address)) {
      console.log(BigNumber.from(l.toString()).toHexString());
    }
    console.log("lucky= " + (await Lottery.getWiningsByAddress(lucky.address)).toBigInt());
    console.log("lucky= ", ethers.utils.formatEther(await Lottery.getPrizeByAddress(lucky.address)));

    console.log("----OLucky Lotteries----");
    for (const l of await await Lottery.getLotterisByAddress(olucky.address)) {
      console.log(BigNumber.from(l.toString()).toHexString());
    }
    console.log("olucky= " + (await Lottery.getWiningsByAddress(olucky.address)).toBigInt());
    console.log("olucky= ", ethers.utils.formatEther(await Lottery.getPrizeByAddress(olucky.address)));

    console.log("contract left balance= " + ethers.utils.formatEther(await ethers.provider.getBalance(Lottery.address)));
  });
});
