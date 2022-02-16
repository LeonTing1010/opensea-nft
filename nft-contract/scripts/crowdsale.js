const { task } = require("hardhat/config");
const { getContract, getEnvVariable } = require("./helpers");
const contractName = "Crowdsale";


task("nft", "Set NFT for the Sales contract")
    .addParam("address", "The nft contract address")
    .setAction(async function (taskArguments, hre) {
        const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"), contractName, hre);
        const transactionResponse = await contract.setNft(taskArguments.address, {
            gasLimit: 500_000,
        });
        console.log(`setNft Transaction Hash: ${transactionResponse.hash}`);
    });

task("limit", "Grants limit to an account")
    .addParam("limit", "The limit of crowdsale")
    .addParam("account", "The account will be able to grant MINT ROLE")
    .setAction(async function (taskArguments, hre) {
        const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"), contractName, hre);
        const transactionResponse = await contract.setLimit(taskArguments.account, taskArguments.limit, {
            gasLimit: 500_000,
        });
        console.log(`Transaction Hash: ${transactionResponse.hash}`);
    });
task("max", "Grants Max limit")
    .addParam("amount", "The Max limit of crowdsale")
    .setAction(async function (taskArguments, hre) {
        const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"), contractName, hre);
        const transactionResponse = await contract.setMaxAmount(taskArguments.amount, {
            gasLimit: 500_000,
        });
        console.log(`Transaction Hash: ${transactionResponse.hash}`);
    });

task("closing", "Set ClosingTime for the Sales contract")
    .addParam("time", "ClosingTime")
    .setAction(async function (taskArguments, hre) {
        const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"), contractName, hre);
        const transactionResponse = await contract.setClosingTime(taskArguments.time, {
            gasLimit: 500_000,
        });
        console.log(`Transaction Hash: ${transactionResponse.hash}`);
    });
task("collect", "Set fee collector")
    .addParam("collector", "Collector")
    .setAction(async function (taskArguments, hre) {
        const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"), contractName, hre);
        const transactionResponse = await contract.setClosingTime(taskArguments.collector, {
            gasLimit: 500_000,
        });
        console.log(`Transaction Hash: ${transactionResponse.hash}`);
    });

task("mint", "Sales the NFT")
    .addParam("amount", "Mining quantity")
    .setAction(async function (taskArguments, hre) {
        const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"), contractName, hre);
        let price = ethers.BigNumber.from("10000000000000000");
        const transactionResponse = await contract.mint(taskArguments.amount, {
            gasLimit: 5_000_000,
            value: price.mul(taskArguments.amount),
        });
        console.log(`Transaction Hash: ${transactionResponse.hash}`);
    });
// task("transfer", "Transfer ownership")
//     .addParam("owner", "New owner")
//     .setAction(async function (taskArguments, hre) {
//         const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"), contractName, hre);
//         await contract.transferOwnership(taskArguments.owner, {
//             gasLimit: 500_000,
//         });
//         const transactionResponse = await contract.grantRole("0x0000000000000000000000000000000000000000000000000000000000000000",
//          taskArguments.owner, {
//             gasLimit: 500_000,
//         });
//         console.log(`Transaction Hash: ${transactionResponse.hash}`);
//     });    

task("withdraw", "Withdraw Payments from the NFT contract")
    .addParam("address", "The address to to send the funds to")
    .setAction(async function (taskArguments, hre) {
        const contract = await getContract(getEnvVariable("SALES_CONTRACT_ADDRESS"), contractName, hre);
        const transactionResponse = await contract.withdrawPayments(taskArguments.address, {
            gasLimit: 500_000,
        });
        console.log(`Transaction Hash: ${transactionResponse.hash}`);
    });

