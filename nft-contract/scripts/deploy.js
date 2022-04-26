const { task } = require("hardhat/config");
const { getContract, getAccount, getEnvVariable } = require("./helpers");

task("check-balance", "Prints out the balance of your account").setAction(async function (taskArguments, hre) {
  const account = getAccount();
  console.log(`Account balance for ${account.address}: ${await account.getBalance()}`);
});

task("deploy-nft", "Deploys the NFT.sol contract").setAction(async function (taskArguments, hre) {
  const nftContractFactory = await hre.ethers.getContractFactory("NFT", getAccount());
  const nft = await nftContractFactory.deploy();
  console.log(`Contract deployed to address: ${nft.address}`);
});

task("deploy-factory", "Deploys the NFTFactoryERC721.sol contract").setAction(async function (taskArguments, hre) {
  const nftContractFactory = await hre.ethers.getContractFactory("NFTFactoryERC721", getAccount());
  const nft = await nftContractFactory.deploy("0x58807bad0b376efc12f5ad86aac70e78ed67deae");
  console.log(`NFTFactoryERC721 deployed to address: ${nft.address}`);
  // const contractNFT = await getContract(taskArguments.nft, "NFT", hre);
  // const grantRole = await contractNFT.grantRole("0xa952726ef2588ad078edf35b066f7c7406e207cb0003bbaba8cb53eba9553e72", nft.address, {
  //   gasLimit: 2_000_000,
  // });
  // console.log(`grant Miner Role Transaction Hash: ${grantRole.hash}`);
});

task("deploy-crowdsale", "Deploys the Crowdsale.sol contract").setAction(async function (taskArguments, hre) {
  const nftContractFactory = await hre.ethers.getContractFactory("Crowdsale", getAccount());
  const nft = await nftContractFactory.deploy();
  console.log(`Contract deployed to address: ${nft.address}`);
});

task("deploy", "Deploys the NFT.sol & Crowdsale.sol contract").setAction(async function (taskArguments, hre) {
  const nftContractFactory = await hre.ethers.getContractFactory("NFT", getAccount());
  const nft = await nftContractFactory.deploy();
  console.log(`NFT Contract deployed to address: ${nft.address}`);

  const salesContractFactory = await hre.ethers.getContractFactory("Crowdsale", getAccount());
  const sales = await salesContractFactory.deploy();
  console.log(`Crowdsales Contract deployed to address: ${sales.address}`);

  const nftAddress = nft.address;
  const salesAddress = sales.address;

  // const nftAddress = getEnvVariable("NFT_CONTRACT_ADDRESS");
  // const salesAddress = getEnvVariable("SALES_CONTRACT_ADDRESS");

  const contractNFT = await getContract(nftAddress, "NFT", hre);
  const contractCrowdsale = await getContract(salesAddress, "Crowdsale", hre);
  const setNft = await contractCrowdsale.setNft(nftAddress, { gasLimit: 2_000_000 });
  console.log(`setNft Transaction Hash: ${setNft.hash}`);
  const grantRole = await contractNFT.grantRole("0xa952726ef2588ad078edf35b066f7c7406e207cb0003bbaba8cb53eba9553e72", salesAddress, {
    gasLimit: 2_000_000,
  });
  console.log(`grant Miner Role Transaction Hash: ${grantRole.hash}`);
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
