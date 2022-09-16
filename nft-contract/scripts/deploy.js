const { task } = require("hardhat/config");
const { getContract, getAccount, getEnvVariable } = require("./helpers");

task("check-balance", "Prints out the balance of your account").setAction(async function (taskArguments, hre) {
  const account = getAccount();
  console.log(`Account balance for ${account.address}: ${await account.getBalance()}`);
});

task("deploy-nft", "Deploys the NFTERC721A.sol contract")
  .addParam("name", "The contract's name")
  .setAction(async function (taskArguments, hre) {
    const nftContractFactory = await hre.ethers.getContractFactory(taskArguments.name, getAccount());
    const nft = await nftContractFactory.deploy();
    console.log(`Contract deployed to address: ${nft.address}`);
  });

task("deploy-crowdsale", "Deploys the Crowdsale.sol contract")
  .addParam("name", "The contract's name")
  .setAction(async function (taskArguments, hre) {
    const nftContractFactory = await hre.ethers.getContractFactory(taskArguments.name, getAccount());
    const nft = await nftContractFactory.deploy({ gasLimit: 5_000_000 });
    console.log(`Contract deployed to address: ${nft.address}`);
  });

task("verify-contract", "verify contract")
  .addParam("name", "The contract's name")
  .setAction(async function (taskArguments, hre) {
    const deployer = getAccount();
    await hre.run("verify:verify", {
      address: taskArguments.name,
      constructorArguments: [],
    });
  });
