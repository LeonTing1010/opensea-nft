const { ethers } = require("ethers");
const { getContractAt } = require("@nomiclabs/hardhat-ethers/internal/helpers");

// Helper method for fetching environment variables from .env
function getEnvVariable(key, defaultValue) {
  if (process.env[key]) {
    return process.env[key];
  }
  if (!defaultValue) {
    throw `${key} is not defined and no default value was provided`;
  }
  return defaultValue;
}

// Helper method for fetching a connection provider to the Ethereum network
function getProvider() {
  return new ethers.providers.Web3Provider(network.provider);
}

// Helper method for fetching a wallet account using an environment variable for the PK
function getAccount() {
  return new ethers.Wallet(getEnvVariable("ACCOUNT_PRIVATE_KEY"), getProvider());
}

// Helper method for fetching a wallet account using an environment variable for the PK
function getBurnAccount() {
  return new ethers.Wallet(getEnvVariable("B_ACCOUNT_PRIVATE_KEY"), getProvider());
}

// Helper method for fetching a contract instance at a given address
function getContract(contractAddress, contractName, hre) {
  const account = getAccount();
  return getContractAt(hre, contractName, contractAddress, account);
}
// Helper method for fetching a contract instance at a given address
function getContract(contractAddress, contractName, account, hre) {
  return getContractAt(hre, contractName, contractAddress, account);
}

module.exports = {
  getEnvVariable,
  getProvider,
  getAccount,
  getContract,
  getBurnAccount,
};
