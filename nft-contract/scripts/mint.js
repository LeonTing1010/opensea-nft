const { task } = require("hardhat/config");
const { getContract, getEnvVariable } = require("./helpers");
const fetch = require("node-fetch");
const contractName = "NFTERC721A";

task("mintTo", "Mints from the NFT contract")
  .addParam("address", "The address to receive a token")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("NFTA_CONTRACT_ADDRESS"), contractName, hre);
    const transactionResponse = await contract.mintTo(taskArguments.address, {
      gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
  });
task("free", "Mints from the NFT contract")
  .addParam("address", "The address to receive a token")
  .addParam("amount", "The amount to mint")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("NFTA_CONTRACT_ADDRESS"), contractName, hre);
    const transactionResponse = await contract.mint(taskArguments.address, taskArguments.amount, {
      gasLimit: 300_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
  });
task("grant", "Add miner ROLE")
  .addParam("miner", "The new miner")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("NFTA_CONTRACT_ADDRESS"), contractName, hre);
    const transactionResponse = await contract.grantRole("0xa952726ef2588ad078edf35b066f7c7406e207cb0003bbaba8cb53eba9553e72", taskArguments.miner, {
      gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
  });

task("set-base-token-uri", "Sets the base token URI for the deployed smart contract")
  .addParam("baseUrl", "The base of the tokenURI endpoint to set")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("NFTA_CONTRACT_ADDRESS"), contractName, hre);
    const transactionResponse = await contract.setBaseTokenURI(taskArguments.baseUrl, {
      gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
  });

task("token-uri", "Fetches the token metadata for the given token ID")
  .addParam("tokenId", "The tokenID to fetch metadata for")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("NFTA_CONTRACT_ADDRESS"), contractName, hre);
    const response = await contract.tokenURI(taskArguments.tokenId, {
      gasLimit: 500_000,
    });

    const metadata_url = response;
    console.log(`Metadata URL: ${metadata_url}`);

    const metadata = await fetch(metadata_url).then((res) => res.json());
    console.log(`Metadata fetch response: ${JSON.stringify(metadata, null, 2)}`);
  });
