// scripts/deployToken.js
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const initialSupply = 1000000; // 1,000,000 tokens

  const MyToken = await hre.ethers.getContractFactory("MyToken");
  const token = await MyToken.deploy(initialSupply);

  await token.deployed();

  console.log("MyToken deployed to:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });