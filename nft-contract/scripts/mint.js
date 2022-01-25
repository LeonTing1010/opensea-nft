const { task } = require("hardhat/config");
const {getContract,getEnvVariable } = require("./helpers");
const fetch = require("node-fetch");

task("nft", "Set NFT for the Sales contract")
.addParam("address", "The nft contract address")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"),"Sales", hre);
    const transactionResponse = await contract.setNftAddress(taskArguments.address, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});

task("grant", "Grants role to account")
.addParam("role", "MINT ROLE be granted")
.addParam("account", "The account will be able to grant MINT ROLE")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"),"Sales", hre);
    const transactionResponse = await contract.grantRole(taskArguments.role,taskArguments.account, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});

task("closing", "Set ClosingTime for the Sales contract")
.addParam("time", "ClosingTime")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"),"Sales", hre);
    const transactionResponse = await contract.setClosingTime(taskArguments.time, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});

task("sale", "Sales the NFT")
.addParam("address", "The address to receive a token")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"),"Sales", hre);
    const transactionResponse = await contract.sale(taskArguments.address, {
        gasLimit: 500_000,
        value: ethers.utils.parseEther("0.01"),
        
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});


task("mint", "Mints from the NFT contract")
.addParam("address", "The address to receive a token")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("NFT_CONTRACT_ADDRESS"), "NFT", hre);
    const transactionResponse = await contract.mintTo(taskArguments.address, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});


task("payments", "Payments Of the NFT contract")
.addParam("address", "The address to to send the funds to")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"),"Sales", hre);
    const transactionResponse = await contract.payments(taskArguments.address, {
        gasLimit: 500_000,  
    });
    console.log(`Transaction: ${transactionResponse}`);
});


task("withdraw", "Withdraw Payments from the NFT contract")
.addParam("address", "The address to to send the funds to")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"),"Sales", hre);
    const transactionResponse = await contract.withdrawPayments(taskArguments.address, {
        gasLimit: 500_000,  
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});


task("set-base-token-uri", "Sets the base token URI for the deployed smart contract")
.addParam("baseUrl", "The base of the tokenURI endpoint to set")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("NFT_CONTRACT_ADDRESS"),"NFT", hre);
    const transactionResponse = await contract.setBaseTokenURI(taskArguments.baseUrl, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});


task("token-uri", "Fetches the token metadata for the given token ID")
.addParam("tokenId", "The tokenID to fetch metadata for")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract(getEnvVariable("NFT_CONTRACT_ADDRESS"),"NFT", hre);
    const response = await contract.tokenURI(taskArguments.tokenId, {
        gasLimit: 500_000,
    });
    
    const metadata_url = response;
    console.log(`Metadata URL: ${metadata_url}`);

    const metadata = await fetch(metadata_url).then(res => res.json());
    console.log(`Metadata fetch response: ${JSON.stringify(metadata, null, 2)}`);
});