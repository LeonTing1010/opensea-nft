require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
// require("@nomiclabs/hardhat-ethers");
require("./scripts/deploy.js");
require("./scripts/mint.js");
require("./scripts/crowdsale.js");
require("./scripts/welfare.js");
// require("@nomiclabs/hardhat-etherscan");
// require("hardhat-gas-reporter");

const { INFURA_KEY, REPORT_GAS, ACCOUNT_PRIVATE_KEY, ETHERSCAN_API_KEY, POLYGONSCAN_API_KEY, NETWORK, ALCHEMY_KEY } = process.env;

module.exports = {
  solidity: "0.8.7",
  defaultNetwork: NETWORK,
  gasReporter: {
    enabled: REPORT_GAS,
    currency: "USD",
    gasPrice: 1000000000,
    runs: 20,
  },
  networks: {
    hardhat: {},
    ropsten: {
      url: `https://ropsten.infura.io/v3/${INFURA_KEY}`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
    },
    ethereum: {
      chainId: 1,
      url: `https://mainnet.infura.io/v3/${INFURA_KEY}`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
      gasPrice: 20000000000,
    },
    maticmum: {
      chainId: 80001,
      // url: `https://polygon-mumbai.infura.io/v3/${INFURA_KEY}`,
      //url: "https://rpc-mumbai.maticvigil.com",
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_KEY}`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_KEY}`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
      urls: {
        apiURL: "https://api-rinkeby.etherscan.io/api",
        browserURL: "https://rinkeby.etherscan.io",
      },
    },
    maas: {
      chainId: 1088,
      url: `http://124.70.219.113:8545`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
    },
    local: {
      url: `http://127.0.0.1:8545/`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: {
      //ethereum
      mainnet: ETHERSCAN_API_KEY,
      ropsten: ETHERSCAN_API_KEY,
      rinkeby: ETHERSCAN_API_KEY,
      goerli: ETHERSCAN_API_KEY,
      kovan: ETHERSCAN_API_KEY,
      //polygon
      polygon: POLYGONSCAN_API_KEY,
      polygonMumbai: POLYGONSCAN_API_KEY,
    },
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
