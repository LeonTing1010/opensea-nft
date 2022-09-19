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
    console.log(`${taskArguments.name} deployed to address: ${nft.address}`);
  });

task("deploy-human", "Deploys the HumanCrowdsale.sol contract").setAction(async function (taskArguments, hre) {
  const Factory = await hre.ethers.getContractFactory("HumanCrowdsale", getAccount());
  const human = await Factory.deploy(getAccount().address, getEnvVariable("HUMAN_ADDRESS"), getEnvVariable("TEASER_ADDRESS"), { gasLimit: 5_000_000 });
  console.log(`HumanCrowdsale deployed to address: ${human.address}`);
  const nft = await getContract(getEnvVariable("HUMAN_ADDRESS"), "Human", hre);
  await nft.grantMinerRole(human.address);
});

task("deploy-halfling", "Deploys the HalflingCrowdsale.sol contract").setAction(async function (taskArguments, hre) {
  const Factory = await hre.ethers.getContractFactory("HalflingCrowdsale", getAccount());
  const halfling = await Factory.deploy(getAccount().address, getEnvVariable("HALFLING_ADDRESS"), getEnvVariable("HUMAN_ADDRESS"), getEnvVariable("POTION_ADDRESS"), { gasLimit: 5_000_000 });
  console.log(`HalflingCrowdsale deployed to address: ${halfling.address}`);
  const nft = await getContract(getEnvVariable("HALFLING_ADDRESS"), "Halfling", hre);
  await nft.grantMinerRole(halfling.address);
});

task("deploy-animal", "Deploys the AnimalCrowdsale.sol contract").setAction(async function (taskArguments, hre) {
  const Factory = await hre.ethers.getContractFactory("AnimalCrowdsale", getAccount());
  const animal = await Factory.deploy(getEnvVariable("ANIMAL_ADDRESS"), getEnvVariable("HUMAN_ADDRESS"), getEnvVariable("POTION_ADDRESS"), getEnvVariable("HALFLING_ADDRESS"), { gasLimit: 5_000_000 });
  console.log(`AnimalCrowdsale deployed to address: ${animal.address}`);
  const nft = await getContract(getEnvVariable("ANIMAL_ADDRESS"), "Animal", hre);
  await nft.grantMinerRole(animal.address);
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
