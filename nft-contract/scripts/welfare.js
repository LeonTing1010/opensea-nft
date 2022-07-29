const { task } = require("hardhat/config");
const { getContract, getAccount, getEnvVariable } = require("./helpers");
const ContractName = "WelfareFoctory";
const ContractKey = "WELFAREFOCTORY_CONTRACT_ADDRESS";

task("newLottery", "New a  Lottery")
  .addParam("l", "The length of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFoctoryContract address=> ${factory}`);
    const lotteryTx = await contract.newLottery(taskArguments.l, {
      gasLimit: 5_000_000,
      gasPrice: 100_000_000_000,
    });
    await lotteryTx.wait();
    const phase = await contract.phase();
    console.log("Phase of Lottery=> " + phase);
    const lottery = await contract.getLottery(phase);
    console.log("New Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    console.log("Consumer=> " + (await contractLottery.randomNumberGenerator()));
    await hre.run("verify:verify", {
      address: contractLottery.address,
      constructorArguments: [phase, 1162, "0x7a1bac17ccc5b313516c5e16fb24f7659aa5ebed", "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f"],
    });
  });
task("verifyLottery", "Verify the  Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFoctoryContract address=> ${factory}`);
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
    console.log("Consumer=> " + (await contractLottery.randomNumberGenerator()));
    await hre.run("verify:verify", {
      address: contractLottery.address,
      constructorArguments: [phase, 1162, "0x7a1bac17ccc5b313516c5e16fb24f7659aa5ebed", "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f"],
    });
  });
task("grantLottery", "Grant Lottery")
  .addParam("phase", "The phase of lottery")
  .addParam("owner", "The owner of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFoctoryContract address=> ${factory}`);
    // const lotteryTx = await contract.newLottery(taskArguments.l, {
    //   gasLimit: 5_000_000,
    //   gasPrice: 100_000_000_000,
    // });
    // await lotteryTx.wait();
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    console.log("Consumer=> " + (await contractLottery.randomNumberGenerator()));
    console.log("transferOwnership=> " + (await contractLottery.transferOwnership(taskArguments.owner, { gasLimit: 5_000_000, gasPrice: 100_000_000_000 })).hash);
    // await hre.run("verify:verify", {
    //   address: contractLottery.address,
    //   constructorArguments: [phase, 1162, "0x7a1bac17ccc5b313516c5e16fb24f7659aa5ebed", "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f"],
    // });
  });
task("getLottery", "Get Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFoctoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    console.log("Consumer=> " + (await contractLottery.randomNumberGenerator()));
  });

task("twistLottery", "Get Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFoctoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    const player = getAccount();
    console.log("Consumer=> " + (await contractLottery.randomNumberGenerator()));
    console.log("twist=> " + (await contractLottery.twist(player.address)).hash);
    console.log("twist=> " + (await contractLottery.twist(player.address)).hash);
  });
