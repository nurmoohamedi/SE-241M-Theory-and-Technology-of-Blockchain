const Web3 = require('web3');
const fs = require('fs');
const path = require('path');

// Read the compiled contract JSON file
const contractPath = path.join(__dirname, '../build/contracts/HelloWorld.json');
const contractJson = JSON.parse(fs.readFileSync(contractPath));

// Read the deployment info
const deploymentPath = path.join(__dirname, '../deployment-info.json');
const deploymentInfo = JSON.parse(fs.readFileSync(deploymentPath));

// Connect to your Ethereum network (local or testnet)
const web3 = new Web3('http://localhost:8545'); // Replace with your network URL

async function interactWithContract() {
    const accounts = await web3.eth.getAccounts();

    const HelloWorld = new web3.eth.Contract(
        contractJson.abi,
        deploymentInfo.address
    );

    // Get the initial message
    const initialMessage = await HelloWorld.methods.getMessage().call();
    console.log('Initial message:', initialMessage);

    // Set a new message
    await HelloWorld.methods.setMessage('Hello Web3!').send({
        from: accounts[0],
        gas: 1000000
    });

    // Get the updated message
    const newMessage = await HelloWorld.methods.getMessage().call();
    console.log('Updated message:', newMessage);
}

interactWithContract()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
