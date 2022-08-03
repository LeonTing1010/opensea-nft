const { BigNumber } = require("ethers");
const { task } = require("hardhat/config");
const { getContract, getAccount, getBurnAccount, getEnvVariable } = require("./helpers");
const ContractName = "WelfareFactory";
const ContractKey = "WELFAREFACTORY_CONTRACT_ADDRESS";

task("newLottery", "New a  Lottery")
  .addParam("l", "The length of lottery")
  .setAction(async function (taskArguments, hre) {
    let arguments = [getEnvVariable("SUB_ID"), getEnvVariable("VRF"), getEnvVariable("KEY_HASH")];
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    const lotteryTx = await contract.newLottery(taskArguments.l, {
      gasLimit: 5_000_000,
    });
    await lotteryTx.wait();
    const phase = await contract.phase();
    console.log("Phase of Lottery=> " + phase);
    const lottery = await contract.getLottery(phase);
    console.log("New Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    console.log("Consumer=> " + (await contractLottery.randomNumberGenerator()));
    // await hre.run("verify:verify", {
    //   address: contractLottery.address,
    //   constructorArguments: [phase, arguments[0], arguments[1], arguments[2]],
    // });
  });
task("verifyLottery", "Verify the  Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    let arguments = [getEnvVariable("SUB_ID"), getEnvVariable("VRF"), getEnvVariable("KEY_HASH")];
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    // const lotteryTx = await contract.newLottery(taskArguments.l, {
    //   gasLimit: 5_000_000,
    //   gasPrice: 100_000_000_000,
    // });
    // await lotteryTx.wait();
    const phase = taskArguments.phase;
    console.log("Phase of Lottery=> " + phase);
    const lottery = await contract.getLottery(phase);
    console.log("New Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    console.log("Consumer=> " + (await contractLottery.randomNumberGenerator()));
    console.log("Arguments=>" + arguments);
    await hre.run("verify:verify", {
      address: lottery,
      constructorArguments: [phase, arguments[0], arguments[1], arguments[2]],
    });
  });
task("grantLottery", "Grant Lottery")
  .addParam("phase", "The phase of lottery")
  .addParam("role", "The owner of lottery")
  .setAction(async function (taskArguments, hre) {
    let arguments = [getEnvVariable("SUB_ID"), getEnvVariable("VRF"), getEnvVariable("KEY_HASH")];
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    // const lotteryTx = await contract.newLottery(taskArguments.l, {
    //   gasLimit: 5_000_000,
    //   gasPrice: 100_000_000_000,
    // });
    // await lotteryTx.wait();
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    console.log("Consumer=> " + (await contractLottery.randomNumberGenerator()));
    console.log("grantRole=> " + (await contractLottery.grantRole("0xdfbefbf47cfe66b701d8cfdbce1de81c821590819cb07e71cb01b6602fb0ee27", taskArguments.role, { gasLimit: 5_000_000 })).hash);
    // await hre.run("verify:verify", {
    //   address: contractLottery.address,
    //   constructorArguments: [phase,  constructorArguments: [phase, arguments[0], arguments[1], arguments[2]],
    // });
  });
task("getLottery", "Get Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    console.log("Consumer=> " + (await contractLottery.randomNumberGenerator()));
  });

task("twistLottery", "Get Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const contractLottery = await getContract(lottery, "Lottery", hre);
    console.log("Consumer=> " + (await contractLottery.randomNumberGenerator()));
    const player1 = getAccount();
    console.log("twist one=> " + (await contractLottery.twist(player1.address)).hash);
    // console.log("twist one=> " + (await contractLottery.twist(player1.address)).hash);
    const player2 = getBurnAccount();
    console.log("twist two=> " + (await contractLottery.twist(player2.address)).hash);
    // console.log("twist two=> " + (await contractLottery.twist(player2.address)).hash);
  });
task("transferToLottery", "Transfer ethers to Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    const player = getAccount();
    // Ether amount to send
    let proportion = "1";
    // await lottery.setProportion(0, ethers.utils.parseEther(proportion), gas);
    // console.log("Proportion of Bonus is " + (await lottery.getProportion(1)));
    // Create a transaction object
    let tx = {
      to: lottery,
      // Convert currency unit from ether to wei
      value: ethers.utils.parseEther(proportion),
    };
    // Send a transaction
    await player.sendTransaction(tx).then((txObj) => {
      console.log("transfer txHash", txObj.hash);
      // => 0x9c172314a693b94853b49dc057cf1cb8e529f29ce0272f451eea8f5741aa9b58
      // A transaction result can be checked in a etherscan with a transaction hash which can be obtained here.
    });
    console.log("contract balance= " + ethers.utils.formatEther(await ethers.provider.getBalance(lottery)));
  });
task("drawLottery", "Draw to Lottery")
  .addParam("phase", "The phase of lottery")
  .setAction(async function (taskArguments, hre) {
    const factory = getEnvVariable(ContractKey);
    const contract = await getContract(factory, ContractName, hre);
    console.log(`WelfareFactoryContract address=> ${factory}`);
    const phase = taskArguments.phase;
    const lottery = await contract.getLottery(phase);
    console.log("Lottery=> " + lottery);
    console.log("contract balance= " + ethers.utils.formatEther(await ethers.provider.getBalance(lottery)));
    const contractLottery = await getContract(lottery, "Lottery", hre);
    const win = "0x0955b32103adc3bf90cfb69511c33767b4df2a11c999d4176e4769ba48d99e15";
    console.log(win);
    await contractLottery.setProportion(1, ethers.utils.parseEther("0.5"));
    console.log("Proportion of Prize is " + (await contractLottery.getProportion(1)));
    console.log("State of Lottery is " + (await contractLottery.state()));

    await contractLottery.testPrize(BigNumber.from(win), { gasLimit: 5_000_000 });
    const player1 = getAccount();
    console.log("----------");
    for (const l of await contractLottery.getTickets(player1.address)) {
      console.log(BigNumber.from(l.toString()).toHexString());
      console.log("Play one result =>" + (await contractLottery.getWinning(l)));
    }
    console.log("Play one getPrize =>" + (await contractLottery.getPrize(player1.address)));
    const player2 = getBurnAccount();
    console.log("----------");
    for (const l of await contractLottery.getTickets(player2.address)) {
      console.log(BigNumber.from(l.toString()).toHexString());
      console.log("Play two result =>" + (await contractLottery.getWinning(l)));
    }
    console.log("Play two getPrize =>" + (await contractLottery.getPrize(player2.address)));

    console.log("contract balance= " + ethers.utils.formatEther(await ethers.provider.getBalance(lottery)));
  });
