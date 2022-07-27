const { BigNumber } = require("ethers");
const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");

describe("Lottery", function () {
  this.timeout(60000000000);
  let Lottery;

  beforeEach(async function () {
    Lottery = await getContract(getEnvVariable("LOTTERY_CONTRACT_ADDRESS"), "Lottery", getAccount(), hre);
    console.log("Lottery=" + Lottery.address);
  });

  it("lottery", async function () {
    const lot = await Lottery.lottery({
      gasLimit: 5_000_000,
    });
    const cr = await lot.wait();

    for (const event of cr.events) {
      console.log(JSON.stringify(event));
    }
  });
  it("calBonus", async function () {
    await Lottery._calBonus(BigNumber.from("51356296693424209065891468090882710476502733463141498304978975329108673582233"), {
      gasLimit: 5_000_000,
    });

    const tx = await Lottery.getLotterisByAddress(getAccount().address);
    console.log("getLotterisByAddress=" + tx);
  });
});
