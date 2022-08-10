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
    await hre.run("verify-quiz");
    await hre.run("verify-welfare");
    await hre.run("verifyLottery", { phase: taskArgs.phase });
  });
task("init-quiz", "init QuizCrowdsale").setAction(async (taskArgs, hre) => {
  //await hre.run("newLottery", { l: "7" });
  // await hre.run("subscribeLottery", { phase: taskArgs.phase });
  await hre.run("grant-role");
});

subtask("grant-role", "Grant QuizCrowdsale & Lottery").setAction(async function (taskArguments, hre) {
  const welfareContract = await getContract(getEnvVariable("WELFAREFACTORY_CONTRACT_ADDRESS"), "WelfareFactory", hre);
  console.log("Welfare=> " + welfareContract.address);
  await welfareContract.grantRole(welfareContract.FACTORY_ROLE(), getEnvVariable("QUIZ_SALES_CONTRACT_ADDRESS"));
  const saleContract = await getContract(getEnvVariable(ContractKey), ContractName, hre);
  const setLottery = await saleContract.setLottery(getEnvVariable("WELFAREFACTORY_CONTRACT_ADDRESS"));
  // const transactionResponse = await setLottery.wait();
  console.log(`setLottery Transaction Hash: ${setLottery.hash}`);
});

task("mint-quiz", "Sales the NFT")
  .addParam("amount", "Mining quantity")
  .addParam("quiz", "Mining quiz")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable(ContractKey), ContractName, hre);
    if (!(await contract.opening())) {
      await contract.setOpening(true, { gasLimit: 5_000_000 });
      await contract.setSLimit(1000, { gasLimit: 5_000_000 });
      await contract.setMLimit(10000, { gasLimit: 5_000_000 });
    }
    let price = ethers.utils.parseEther("0.01");
    const transactionResponse = await contract.mint(taskArguments.amount, taskArguments.quiz, {
      gasLimit: 5_000_000,
      value: price.mul(taskArguments.amount),
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
  });

task("gift-quiz", "Gift the quizes").setAction(async function (taskArguments, hre) {
  const contract = await getContract(getEnvVariable(ContractKey), ContractName, hre);
  const quiz = await contract.getQuizes(getAccount().address);
  console.log("Quizes=> " + JSON.stringify(quiz));
  if (await contract.opening()) {
    await contract.setOpening(false, { gasLimit: 5_000_000 });
  }
  const options = [];
  for (var i = 0; i < quiz.length; i++) {
    options.push(1);
  }
  await contract.gift(options, { gasLimit: 5_000_000 });
});
task("gift-lottery", "Gift the lotteries").setAction(async function (taskArguments, hre) {
  const contract = await getContract(getEnvVariable(ContractKey), ContractName, hre);
  console.log("welfareFactory => " + (await contract.welfareFactory()));
  console.log("Quizes Before => " + (await contract.getLotteries(getAccount().address)));
  await contract.lottery({ gasLimit: 10_000_000 });
  console.log("Quizes End => " + (await contract.getLotteries(getAccount().address)));
});

task("quiz-transfer", "Transfer ownership to new Owner").setAction(async function (taskArguments, hre) {
  const contract = await getContract(getEnvVariable(ContractKey), ContractName, hre);
  await contract.transferLotteryOwnership(getAccount().address, { gasLimit: 10_000_000 });

  console.log("WelfareFactory => " + (await contract.welfareFactory()));
  const welfareFactory = await getContract(await contract.welfareFactory(), "WelfareFactory", hre);
  const phase = await welfareFactory.phase();
  console.log("Phase => " + phase);
  await hre.run("subscribeLottery", { phase: phase });

  for (var i = 1; i <= phase; i++) {
    const lottery = await getContract(await welfareFactory.getLottery(i), "Lottery", hre);
    console.log("Lottery => " + lottery.address);
    await lottery.draw();
    await lottery.payout();
  }
});
