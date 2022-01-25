require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("./scripts/deploy.js");
require("./scripts/mint.js");
require("./scripts/crowdsale.js");
require("@nomiclabs/hardhat-etherscan");

const { INFURA_KEY, ACCOUNT_PRIVATE_KEY, ETHERSCAN_API_KEY, NETWORK } = process.env;

module.exports = {
  solidity: "0.8.7",
  defaultNetwork: NETWORK,
  networks: {
    hardhat: {},
    ropsten: {
      url: `https://ropsten.infura.io/v3/${INFURA_KEY}`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
    },
    ethereum: {
      chainId: 1,
      url: `https://mainnet.infura.io/v3/${INFURA_KEY}`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
    },
    maticmum: {
      url: `https://polygon-mumbai.infura.io/v3/${INFURA_KEY}`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
}
