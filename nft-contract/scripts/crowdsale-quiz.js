const { task } = require("hardhat/config");
const { getContract, getEnvVariable } = require("./helpers");
const ContractName = "QuizCrowdsale";
const ContractKey = "QUIZ_SALES_CONTRACT_ADDRESS";

task("mint-quiz", "Sales the NFT")
  .addParam("amount", "Mining quantity")
  .addParam("quiz", "Mining quiz")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable(ContractKey), ContractName, hre);
    await contract.setOpening(true);
    let price = ethers.utils.parseEther("0.15");
    const transactionResponse = await contract.mint(taskArguments.amount, taskArguments.quiz, {
      gasLimit: 2_000_000,
      value: price.mul(taskArguments.amount),
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
  });
