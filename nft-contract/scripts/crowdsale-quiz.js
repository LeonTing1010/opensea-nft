const { task } = require("hardhat/config");
const { BigNumber } = require("ethers");
const { getContract, getContractAt, getEnvVariable, getBurnAccount, getAccount } = require("./helpers");
const ContractName = "QuizCrowdsale";
const ContractKey = "QUIZ_SALES_CONTRACT_ADDRESS";

task("deploy-quizcrowdsale", "deploy QuizCrowdsale").setAction(async (taskArgs, hre) => {
  await hre.run("deploy-quiz");
  await hre.run("deploy-welfare");
});
task("verify-quizcrowdsale", "deploy QuizCrowdsale")
  .addParam("phase", "Phase of Lottery")
  .setAction(async (taskArgs, hre) => {
    // await hre.run("verify-quiz");
    // await hre.run("verify-welfare");
    await hre.run("verifyLottery", { phase: taskArgs.phase });
  });
task("init-quiz", "init QuizCrowdsale")
  .addParam("phase", "Phase of Lottery")
  .setAction(async (taskArgs, hre) => {
    await hre.run("newLottery", { l: "7" });
    await hre.run("subscribeLottery", { phase: taskArgs.phase });
    await hre.run("grant-role", { phase: taskArgs.phase });
  });

subtask("grant-role", "Grant QuizCrowdsale & Lottery")
  .addParam("phase", "Phase of Lottery")
  .setAction(async function (taskArguments, hre) {
    const phase = taskArguments.phase;
    console.log("Phase of Lottery=> " + phase);
    const lottery = await (await getContract(getEnvVariable("WELFAREFACTORY_CONTRACT_ADDRESS"), "WelfareFactory", hre)).getLottery(phase);
    console.log("Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    await contractLottery.grantLotteryRole(getEnvVariable("QUIZ_SALES_CONTRACT_ADDRESS"));
    const contract = await getContract(getEnvVariable(ContractKey), ContractName, hre);
    const setLottery = await contract.setLottery(contractLottery.address);
    // const transactionResponse = await setLottery.wait();
    console.log(`setLottery Transaction Hash: ${setLottery.hash}`);
  });

task("mint-quiz", "Sales the NFT")
  .addParam("amount", "Mining quantity")
  .addParam("quiz", "Mining quiz")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable(ContractKey), ContractName, hre);
    await contract.setOpening(true, { gasLimit: 5_000_000 });
    let price = ethers.utils.parseEther("0.01");
    const transactionResponse = await contract.mint(taskArguments.amount, taskArguments.quiz, {
      gasLimit: 5_000_000,
      value: price.mul(taskArguments.amount),
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
  });

task("gift-quiz", "Gift the Lotteries").setAction(async function (taskArguments, hre) {
  const contract = await getContract(getEnvVariable(ContractKey), ContractName, hre);
  const quiz = await contract.getQuizes(getAccount().address);
  console.log("Quizes=> " + JSON.stringify(quiz));
  // if (await contract.opening()) {
  //   await contract.setOpening(false, { gasLimit: 5_000_000 });
  // }
  // const options = [1, 1];
  // await contract.gift(options, { gasLimit: 5_000_000 });
});
