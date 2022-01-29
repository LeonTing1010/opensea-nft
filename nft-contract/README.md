# Crowdsale
```shell
npx hardhat compile
npx hardhat deploy-crowdsale
npx hardhat nft --address NFT_CONTRACT_ADDRESS
npx hardhat limit --limit LIMIT --account ACCOUNT
npx hardhat closing --time TIME
npx hardhat mint
```
# 部署步骤
1. 修改NFT合约最大供给量
2. 部署NFT合约，并修改 .env配置参数
3. 修改Crowdsale合约最小价格，最大购买数量
4. 部署Crowdsale合约，并修改 .env配置参数
5. 设置Crowdsale合约对应的NFT合约，并将Crowdsale合约赋值为NFT合约挖矿角色
6. 设置开始时间和结束时间
7. 设置白名单
