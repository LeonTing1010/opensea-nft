const { BigNumber } = require("ethers");
const { task } = require("hardhat/config");
const { getContract, getAccount, getBurnAccount, getEnvVariable } = require("./helpers");
const ContractName = "WelfareFactory";
const ContractKey = "WELFAREFACTORY_CONTRACT_ADDRESS";
const gas = { gasLimit: 5_000_000 };

task("newLottery", "New a  Lottery").setAction(async function (taskArguments, hre) {
  const factory = getEnvVariable(ContractKey);
  const contract = await getContract(factory, ContractName, hre);
  console.log(`WelfareFactoryContract address=> ${factory}`);
  const lotteryTx = await contract.newLottery(gas);
  await lotteryTx.wait();
  const phase = await contract.phase();
  console.log("Phase of Lottery=> " + phase);
  const lottery = await contract.getLottery(phase);
  console.log("New Lottery=> " + lottery);
});
subtask("subscribeLottery", "Subscribe the  Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    let arguments = [getEnvVariable("SUB_ID"), getEnvVariable("VRF"), getEnvVariable("KEY_HASH")];
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    console.log("Phase of Lottery=> " + phase);
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    const consumer = await contractLottery.rng();
    console.log("Consumer=> " + consumer);
    const coordinatorContract = await getContract(arguments[1], "VRFCoordinatorV2Interface", hre);
    const subscription = await coordinatorContract.addConsumer(arguments[0], consumer);
    console.log("subscription =>" + JSON.stringify(subscription));
  });

task("verify-lottery", "Verify the  Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    let arguments = [getEnvVariable("SUB_ID"), getEnvVariable("VRF"), getEnvVariable("KEY_HASH")];
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    await hre.run("verify:verify", {
      address: factory,
      constructorArguments: [arguments[0], arguments[1], arguments[2]],
    });
    // const lotteryTx = await contract.newLottery(taskArguments.l, {
    //   gasLimit: 5_000_000,
    //   gasPrice: 100_000_000_000,
    // });
    // await lotteryTx.wait();
    const phase = taskArguments.phase;
    console.log("Phase of Lottery=> " + phase);
    const lottery = await contract.getLottery(phase);
    console.log("New Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    console.log("Consumer=> " + (await contractLottery.rng()));
    console.log("Arguments=>" + arguments);
    await hre.run("verify:verify", {
      address: lottery,
      constructorArguments: [phase],
    });
  });
task("grantLottery", "Grant Lottery")
  .addParam("phase", "The phase of lottery")
  // .addParam("role", "The owner of lottery")
  .setAction(async function (taskArguments, hre) {
    let arguments = [getEnvVariable("SUB_ID"), getEnvVariable("VRF"), getEnvVariable("KEY_HASH")];
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    // const lotteryTx = await contract.newLottery(taskArguments.l, {
    //   gasLimit: 5_000_000,
    //   gasPrice: 100_000_000_000,
    // });
    // await lotteryTx.wait();
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    console.log("Consumer=> " + (await contractLottery.rng()));
    console.log("grantRole=> " + (await contractLottery.grantLotteryRole(getAccount().address, gas)).hash);
    // await hre.run("verify:verify", {
    //   address: contractLottery.address,
    //   constructorArguments: [phase,  constructorArguments: [phase, arguments[0], arguments[1], arguments[2]],
    // });
  });
task("getLottery", "Get Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    console.log("Consumer=> " + (await contractLottery.rng()));
  });

task("twistLottery", "Get Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    console.log("Consumer=> " + (await contractLottery.rng()));
    const player1 = getAccount();
    console.log("twist one=> " + (await contractLottery.twist(player1.address, 10, 1, gas)).hash);
    // console.log("twist one=> " + (await contractLottery.twist(player1.address)).hash);
    const player2 = getBurnAccount();
    console.log("twist two=> " + (await contractLottery.twist(player2.address, 10, 2, gas)).hash);
    // console.log("twist two=> " + (await contractLottery.twist(player2.address)).hash);
  });
task("transferToLottery", "Transfer ethers to Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const player = getAccount();
    // Ether amount to send
    let proportion = "1";
    // await lottery.setProportion(0, ethers.utils.parseEther(proportion), gas);
    // console.log("Proportion of Bonus is " + (await lottery.getProportion(1)));
    // Create a transaction object
    let tx = {
      to: lottery,
      // Convert currency unit from ether to wei
      value: ethers.utils.parseEther(proportion),
    };
    // Send a transaction
    await player.sendTransaction(tx).then((txObj) => {
      console.log("transfer txHash", txObj.hash);
      // => 0x9c172314a693b94853b49dc057cf1cb8e529f29ce0272f451eea8f5741aa9b58
      // A transaction result can be checked in a etherscan with a transaction hash which can be obtained here.
    });
    console.log("contract balance= " + ethers.utils.formatEther(await ethers.provider.getBalance(lottery)));
  });
task("drawLottery", "Draw to Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    console.log("contract balance= " + ethers.utils.formatEther(await ethers.provider.getBalance(lottery)));
    const contractLottery = await getContract(lottery, "Lottery", hre);
    const win = "0x0955b32103adc3bf90cfb69511c33767b4df2a11c999d4176e4769ba48d99e15";
    console.log(win);
    await contractLottery.setProportion(1, ethers.utils.parseEther("0.5"));
    console.log("Proportion of Prize is " + (await contractLottery.getProportion(1)));
    console.log("State of Lottery is " + (await contractLottery.state()));

    await contractLottery.testPrize(BigNumber.from(win), { gasLimit: 5_000_000 });
    const player1 = getAccount();
    console.log("----------");
    for (const l of await contractLottery.getTickets(player1.address)) {
      console.log(BigNumber.from(l.toString()).toHexString());
      console.log("Play one result =>" + (await contractLottery.getWinning(l)));
    }
    console.log("Play one getPrize =>" + (await contractLottery.getPrize(player1.address)));
    const player2 = getBurnAccount();
    console.log("----------");
    for (const l of await contractLottery.getTickets(player2.address)) {
      console.log(BigNumber.from(l.toString()).toHexString());
      console.log("Play two result =>" + (await contractLottery.getWinning(l)));
    }
    console.log("Play two getPrize =>" + (await contractLottery.getPrize(player2.address)));

    console.log("contract balance= " + ethers.utils.formatEther(await ethers.provider.getBalance(lottery)));
  });

task("getTickets", "Get Tickets")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);

    const player1 = getAccount();
    console.log("getTickets one=> " + (await contractLottery.getTickets(player1.address)));
    // console.log("twist one=> " + (await contractLottery.twist(player1.address)).hash);
    const player2 = getBurnAccount();
    console.log("getTickets two=> " + (await contractLottery.getTickets(player2.address)));
    // console.log("twist two=> " + (await contractLottery.twist(player2.address)).hash);
  });

task("setWinnings", "setWinnings Tickets")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("setWinnings=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    await contractLottery.setWinnings([1, 2, 3, 4], [4000000000, 3000000000, 2000000000, 1000000000], gas);
    await contractLottery._testSetWinningNumbers([13, 14, 5, 16, 13, 13, 3, 3, 13, 1, 21, 0, 7, 8, 8, 9, 10, 11], gas);
    await contractLottery.winning(gas);
    console.log("Winners=> " + (await contractLottery.winners()));
    for (var i = 0; i < 20; i++) {
      console.log(i + " Winer=> " + (await contractLottery.getWinner(i)));
    }
  });
task("getPrizes", "lottery getPrizes")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    console.log("Prizes=> " + (await contractLottery.getPrizes()));
  });
task("payout-lottery", "payout prize")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    const account = getBurnAccount();
    console.log("Balance Before=> " + (await account.getBalance()));
    await contractLottery.payout([account.address], [BigNumber.from("3000000000000000000").toHexString()], { value: ethers.utils.parseEther("0.01"), gasLimit: 5_000_000 });
    console.log("Balance End=> " + (await account.getBalance()));
  });
task("test-welfare", "Test Welfare")
  .addParam("phase", "Phase of Lottery")
  .setAction(async (taskArgs, hre) => {
    await hre.run("newLottery");
    await hre.run("grantLottery", { phase: taskArgs.phase });
    await hre.run("twistLottery", { phase: taskArgs.phase });
    await hre.run("setWinnings", { phase: taskArgs.phase });
    await hre.run("getPrizes", { phase: taskArgs.phase });
  });
