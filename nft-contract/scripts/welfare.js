const { task } = require("hardhat/config");
const { getContract, getEnvVariable } = require("./helpers");
const ContractName = "WelfareFoctory";
const ContractKey = "WELFAREFOCTORY_CONTRACT_ADDRESS";

task("newLottery", "New a  Lottery")
  .addParam("len", "The length of lottery")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable(ContractKey), ContractName, hre);
    const lotteryTx = await contract.newLottery(taskArguments.len, {
      gasLimit: 500_000,
    });
    await lotteryTx.wait();
    const phase = await contract.phase();
    const lottery = await contract.getLottery(phase);
    console.log("New Lottery=> " + lottery);
    console.log("Consumer=> " + (await contract.randomNumberGenerator()));
    await hre.run("verify:verify", {
      address: lottery,
      constructorArguments: [phase, 1162, "0x7a1bac17ccc5b313516c5e16fb24f7659aa5ebed", "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f"],
    });
  });
