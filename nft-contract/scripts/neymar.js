const { task } = require("hardhat/config");
const { getContract, getEnvVariable } = require("./helpers");
const ContractName = "Crowdsale";
const ContractKey = "SALES_CONTRACT_ADDRESS";

task("init", "Deploy contracts").setAction(async function (taskArguments, hre) {
  await hre.run("deploy-nft", { name: "Teaser" });
  await hre.run("deploy-nft", { name: "Human" });
  await hre.run("deploy-nft", { name: "Potion" });
  await hre.run("deploy-nft", { name: "Halfling" });
  await hre.run("deploy-nft", { name: "Animal" });
  await hre.run("deploy-crowdsale", { name: "Animal" });
});
