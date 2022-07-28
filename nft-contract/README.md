# Crowdsale

```shell
npx hardhat compile
npx hardhat deploy-crowdsale
npx hardhat nft --address NFT_CONTRACT_ADDRESS
npx hardhat limit --limit LIMIT --account ACCOUNT
npx hardhat closing --time TIME
npx hardhat mint
npx hardhat verify --constructor-args arguments.js
```

# 部署步骤

1. 修改 NFT 合约最大供给量
2. 部署 NFT 合约，并修改 .env 配置参数
3. 修改 Crowdsale 合约最小价格，最大购买数量
4. 部署 Crowdsale 合约，并修改 .env 配置参数
5. 设置 Crowdsale 合约对应的 NFT 合约，并将 Crowdsale 合约赋值为 NFT 合约挖矿角色
6. 设置开始时间和结束时间
7. 设置白名单
