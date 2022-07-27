const { task } = require("hardhat/config");
const { getContract, getAccount, getEnvVariable } = require("./helpers");

task("check-balance", "Prints out the balance of your account").setAction(async function (taskArguments, hre) {
  const account = getAccount();
  console.log(`Account balance for ${account.address}: ${await account.getBalance()}`);
});

task("deploy-nfta", "Deploys the NFTERC721A.sol contract").setAction(async function (taskArguments, hre) {
  const nftContractFactory = await hre.ethers.getContractFactory("NFTERC721A", getAccount());
  const nft = await nftContractFactory.deploy();
  console.log(`Contract deployed to address: ${nft.address}`);
});
task("deploy-nft", "Deploys the NFTERC721.sol contract").setAction(async function (taskArguments, hre) {
  const nftContractFactory = await hre.ethers.getContractFactory("NFTERC721", getAccount());
  const nft = await nftContractFactory.deploy();
  console.log(`Contract deployed to address: ${nft.address}`);
});

task("deploy-factory", "Deploys the NFTFactoryERC721.sol contract").setAction(async function (taskArguments, hre) {
  const nftContractFactory = await hre.ethers.getContractFactory("NFTFactoryERC721", getAccount());
  const nft = await nftContractFactory.deploy("0x58807bad0b376efc12f5ad86aac70e78ed67deae"); //rinkeby
  //0xa5409ec958c83c3f309868babaca7c86dcb077c1 main
  console.log(`NFTFactoryERC721 deployed to address: ${nft.address}`);
  // const contractNFT = await getContract(taskArguments.nft, "NFT", hre);
  // const grantRole = await contractNFT.grantRole("0xa952726ef2588ad078edf35b066f7c7406e207cb0003bbaba8cb53eba9553e72", nft.address, {
  //   gasLimit: 2_000_000,
  // });
  // console.log(`grant Miner Role Transaction Hash: ${grantRole.hash}`);
});

task("deploy-crowdsale", "Deploys the Crowdsale.sol contract").setAction(async function (taskArguments, hre) {
  const nftContractFactory = await hre.ethers.getContractFactory("Crowdsale", getAccount());
  const nft = await nftContractFactory.deploy({ gasLimit: 5_000_000 });
  console.log(`Contract deployed to address: ${nft.address}`);
});

task("deploy", "Deploys the NFTERC721A.sol & Crowdsale.sol contract").setAction(async function (taskArguments, hre) {
  const deployer = getAccount();
  const nftContractFactory = await hre.ethers.getContractFactory("NFTERC721A", deployer);
  const nft = await nftContractFactory.deploy("0xff7Ca10aF37178BdD056628eF42fD7F799fAc77c");
  //0xf57b2c51ded3a29e6891aba85459d600256cf317 rinkby
  console.log(`NFT Contract deployed to address: ${nft.address}`);

  const salesContractFactory = await hre.ethers.getContractFactory("Crowdsale", deployer);
  const sales = await salesContractFactory.deploy(deployer.address, nft.address, { gasLimit: 5_000_000 });
  console.log(`Crowdsale Contract deployed to address: ${sales.address}`);
  //npx hardhat verify 0xaD57e80ECCF6f216C0efeBad75a00eA4BB5e34F2 0x7e76e2dc706da155c30ca5c1e2c4582b8bec786e 0x605b987b6309Be6C17ec911403C88668e087a9F1

  const nftAddress = nft.address;
  const salesAddress = sales.address;

  // const nftAddress = getEnvVariable("NFT_CONTRACT_ADDRESS");
  // const salesAddress = getEnvVariable("SALES_CONTRACT_ADDRESS");

  // const contractNFT = await getContract(nftAddress, "NFTERC721A", hre);
  // const contractCrowdsale = await getContract(salesAddress, "Crowdsale", hre);

  // const setNft = await sales.setNft(nftAddress, { gasLimit: 5_000_000 });
  // console.log(`setNft Transaction Hash: ${setNft.hash}`);
  const grantRole = await nft.grantRole("0xa952726ef2588ad078edf35b066f7c7406e207cb0003bbaba8cb53eba9553e72", salesAddress, {
    gasLimit: 5_000_000,
  });
  console.log(`grant Miner Role Transaction Hash: ${grantRole.hash}`);
});

task("verify-contract", "verify contract").setAction(async function (taskArguments, hre) {
  const nftAddress = getEnvVariable("NFTA_CONTRACT_ADDRESS");
  const salesAddress = getEnvVariable("SALES_CONTRACT_ADDRESS");
  const deployer = getAccount();

  // hre.run("verify:verify", {
  //   address: nftAddress,
  //   constructorArguments: ["0xff7Ca10aF37178BdD056628eF42fD7F799fAc77c"],
  // });
  await hre.run("verify:verify", {
    address: salesAddress,
    constructorArguments: [deployer.address, nftAddress],
  });
});

task("init", "Init the NFT.sol & Crowdsale.sol contract").setAction(async function (taskArguments, hre) {
  const nftAddress = getEnvVariable("NFT_CONTRACT_ADDRESS");
  const salesAddress = getEnvVariable("SALES_CONTRACT_ADDRESS");

  const contractNFT = await getContract(nftAddress, "NFT", hre);
  const contractCrowdsale = await getContract(salesAddress, "Crowdsale", hre);
  const setNft = await contractCrowdsale.setNft(nftAddress, { gasLimit: 5_000_000 });
  console.log(`setNft Transaction Hash: ${setNft.hash}`);
  const miner = await getAccount().getAddress();
  const grantRole = await contractNFT.grantRole("0xa952726ef2588ad078edf35b066f7c7406e207cb0003bbaba8cb53eba9553e72", salesAddress, {
    gasLimit: 5_000_000,
  });
  console.log(`grant Miner Role Transaction Hash: ${grantRole.hash}`);
});

task("transfer", "Transfer ownership")
  .addParam("owner", "The new owner")
  .setAction(async function (taskArguments, hre) {
    const nftAddress = getEnvVariable("NFT_CONTRACT_ADDRESS");
    const salesAddress = getEnvVariable("SALES_CONTRACT_ADDRESS");
    const contractNFT = await getContract(nftAddress, "NFT", hre);
    const contractCrowdsale = await getContract(salesAddress, "Crowdsale", hre);

    await contractNFT.grantRole("0x0000000000000000000000000000000000000000000000000000000000000000", taskArguments.owner, {
      gasLimit: 5_000_000,
    });
    await contractCrowdsale.grantRole("0x0000000000000000000000000000000000000000000000000000000000000000", taskArguments.owner, {
      gasLimit: 5_000_000,
    });

    const oldOwner = await getAccount().getAddress();
    await contractCrowdsale.revokeRole("0x0000000000000000000000000000000000000000000000000000000000000000", oldOwner, {
      gasLimit: 5_000_000,
    });
    await contractNFT.revokeRole("0x0000000000000000000000000000000000000000000000000000000000000000", oldOwner, {
      gasLimit: 5_000_000,
    });
    await contractNFT.transferOwnership(taskArguments.owner, { gasLimit: 5_000_000 });
    const transferOwnership = await contractCrowdsale.transferOwnership(taskArguments.owner, { gasLimit: 5_000_000 });
    console.log(`transferOwnership Transaction Hash: ${transferOwnership.hash}`);
  });

task("deploy-lottery", "Deploys the Lottery.sol & RandomNumberGenerator.sol contract").setAction(async function (taskArguments, hre) {
  const RandomNumberGeneratorContractFactory = await hre.ethers.getContractFactory("RandomNumberGenerator", getAccount());
  const randomNumberGenerator = await RandomNumberGeneratorContractFactory.deploy(1162, "0x7a1bac17ccc5b313516c5e16fb24f7659aa5ebed", "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f", { gasLimit: 5_000_000 });
  console.log(`RandomNumberGeneratorContract deployed to address: ${randomNumberGenerator.address}`);

  const LotteryContractFactory = await hre.ethers.getContractFactory("Lottery", getAccount());
  const lottery = await LotteryContractFactory.deploy(randomNumberGenerator.address, { gasLimit: 5_000_000 });
  randomNumberGenerator.transferOwnership(lottery.address);
  console.log(`LotteryContract deployed to address: ${lottery.address}`);
});
