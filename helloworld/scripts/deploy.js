const Web3 = require("web3");
const fs = require("fs");
const path = require("path");

// Read the compiled contract JSON file
const contractPath = path.join(__dirname, "../build/contracts/HelloWorld.json");
const contractJson = JSON.parse(fs.readFileSync(contractPath));

// Connect to your Ethereum network (local or testnet)
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545")); // Replace with your network URL

async function deployContract() {
  const accounts = await web3.eth.getAccounts();
  console.log("Attempting to deploy from account:", accounts[0]);

  const HelloWorld = new web3.eth.Contract(contractJson.abi);
  const deployedContract = await HelloWorld.deploy({
    data: contractJson.bytecode,
  }).send({
    from: accounts[0],
    gas: 1500000,
    gasPrice: "30000000000",
  });

  console.log(
    "Contract deployed at address:",
    deployedContract.options.address,
  );

  // Save the deployed address for later use
  const deploymentInfo = {
    address: deployedContract.options.address,
    network: await web3.eth.net.getNetworkType(),
  };

  fs.writeFileSync(
    path.join(__dirname, "../deployment-info.json"),
    JSON.stringify(deploymentInfo, null, 2),
  );
}

deployContract()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
