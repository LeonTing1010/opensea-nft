const { getContract, getEnvVariable, getAccount, getBurnAccount, getProvider } = require("./helpers");

describe("Lottery", function () {
  this.timeout(60000000000);
  let Lottery;

  beforeEach(async function () {
    Lottery = await getContract(getEnvVariable("LOTTERY_CONTRACT_ADDRESS"), "Lottery", getAccount(), hre);
    console.log("Lottery=" + Lottery.address);
  });

  it("submitNumber", async function () {
    for (var i = 1; i <= 3; i++) {
      await Lottery.submitNumber(i, {
        gasLimit: 5_000_000,
      });
    }
    const numberOfEntries = await Lottery.numberOfEntries();
    console.log("numberOfEntries=" + numberOfEntries);

    // Receive an event when ANY submitNumber occurs
    Lottery.on("NewEntry", (player, number, event) => {
      console.log(`${player} submitNumber ${number}`);
      // The event object contains the verbatim log data, the
      // EventFragment and functions to fetch the block,
      // transaction and receipt and event functions
    });
  });
  it("drawNumber", async function () {
    await Lottery.drawNumber({
      gasLimit: 5_000_000,
    });
    // Receive an event when ANY submitNumber occurs
    Lottery.on("NumberRequested", (requestId, event) => {
      console.log(`NumberRequested ${requestId}`);
      // The event object contains the verbatim log data, the
      // EventFragment and functions to fetch the block,
      // transaction and receipt and event functions
    });
  });
});
