const { task } = require("hardhat/config");
const { getContract, getEnvVariable, getAccount } = require("./helpers");
const { signWhitelist, signGiftlist } = require("../scripts/signList");

task("init-nft", "Deploy contracts").setAction(async function (taskArguments, hre) {
  await hre.run("deploy-nft", { name: "Teaser" });
  await hre.run("deploy-nft", { name: "Human" });
  await hre.run("deploy-nft", { name: "Potion" });
  await hre.run("deploy-nft", { name: "Halfling" });
  await hre.run("deploy-nft", { name: "Animal" });
});
task("init-crowdsale", "Deploy contracts").setAction(async function (taskArguments, hre) {
  await hre.run("deploy-human");
  await hre.run("deploy-halfling");
  await hre.run("deploy-animal");
});

task("test-crowdsale", "Deploy contracts")
  .addParam("id", "The tokenId of mint")
  .setAction(async function (taskArguments, hre) {
    // await hre.run("init-nft");
    // await hre.run("init-crowdsale");
    await hre.run("human-allow-mint");
    await hre.run("human-white-mint");
    await hre.run("human-pub-mint");
    await hre.run("halfling-mint");
    await hre.run("animal-mint", { tokenId: taskArguments.id });
  });

task("human-allow-mint", "Human allowMint").setAction(async function (taskArguments, hre) {
  const miner = getAccount();
  const contract = await getContract(getEnvVariable("HUMAN_CROWDSALE_ADDRESS"), "HumanCrowdsale", hre);
  await contract.setAllow(true);
  contract.setSigningKey(miner.address);
  let { chainId } = await ethers.provider.getNetwork();
  const nonce = await contract.getUserNonce(miner.address);
  const sig = await signGiftlist("HUMAN", chainId, contract.address, miner, miner.address, nonce);
  console.log("signature = " + sig);

  let price = ethers.utils.parseEther("0.25");
  const transactionResponse = await contract.allowMint(3, sig, {
    gasLimit: 200_000,
    value: price.mul(3),
  });
  console.log("human-allow-mint = " + transactionResponse.hash);
});
task("human-white-mint", "Human whiteMint").setAction(async function (taskArguments, hre) {
  const miner = getAccount();
  const contract = await getContract(getEnvVariable("HUMAN_CROWDSALE_ADDRESS"), "HumanCrowdsale", hre);
  await contract.setWhite(true);
  const teaser = await getContract(getEnvVariable("TEASER_ADDRESS"), "Teaser", hre);
  const ts = await teaser.tokensOfOwner(miner.address);
  console.log("Teaser tokensOfOwner = " + ts);
  if (ts == 0) {
    await teaser.mint({
      gasLimit: 200_000,
    });
  }
  let price = ethers.utils.parseEther("0.25");
  const transactionResponse = await contract.whiteMint(3, {
    gasLimit: 200_000,
    value: price.mul(3),
  });
  console.log("human-white-mint = " + transactionResponse.hash);
});

task("human-pub-mint", "Human publicMint").setAction(async function (taskArguments, hre) {
  const miner = getAccount();
  const contract = await getContract(getEnvVariable("HUMAN_CROWDSALE_ADDRESS"), "HumanCrowdsale", hre);
  await contract.setPub(true);
  let price = ethers.utils.parseEther("0.25");
  const transactionResponse = await contract.whiteMint(3, {
    gasLimit: 200_000,
    value: price.mul(3),
  });
  console.log("human-pub-mint = " + transactionResponse.hash);
});
task("halfling-mint", "Halfling mint").setAction(async function (taskArguments, hre) {
  const miner = getAccount();
  const contract = await getContract(getEnvVariable("HALFLING_CROWDSALE_ADDRESS"), "HalflingCrowdsale", hre);
  await contract.setAllow(true);
  const potion = await getContract(getEnvVariable("POTION_ADDRESS"), "Potion", hre);

  await potion.mintTo(miner.address, {
    gasLimit: 200_000,
  });

  let price = ethers.utils.parseEther("0.35");
  const transactionResponse = await contract.mint(3, {
    gasLimit: 900_000,
    value: price.mul(3),
  });
  console.log("halfling-mint = " + transactionResponse.hash);
});

task("animal-mint", "Animal mint")
  .addParam("tokenId", "The tokenId to be burned")
  .setAction(async function (taskArguments, hre) {
    const miner = getAccount();
    const crowdsale = getEnvVariable("ANIMAL_CROWDSALE_ADDRESS");
    const contract = await getContract(crowdsale, "AnimalCrowdsale", hre);
    await contract.setAllow(true);
    const potion = await getContract(getEnvVariable("POTION_ADDRESS"), "Potion", hre);
    const halfling = await getContract(getEnvVariable("HALFLING_ADDRESS"), "Halfling", hre);

    await potion.setApprovalForAll(crowdsale, true);
    await halfling.setApprovalForAll(crowdsale, true);

    // await potion.mintTo(miner.address, {
    //   gasLimit: 200_000,
    // });

    const transactionResponse = await contract.mint(taskArguments.tokenId, taskArguments.tokenId, {
      gasLimit: 900_000,
    });
    console.log("animal-mint = " + transactionResponse.hash);

    const animal = await getContract(await contract.token(), "Animal", hre);
    const balance = await animal.balanceOf(miner.address);
    console.log("balance = " + balance);
  });
