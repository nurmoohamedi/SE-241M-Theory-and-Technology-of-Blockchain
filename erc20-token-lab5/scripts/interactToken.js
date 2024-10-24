// scripts/interactToken.js
const hre = require("hardhat");

async function main() {
  const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // Replace with actual address
  const MyToken = await hre.ethers.getContractFactory("MyToken");
  const token = await MyToken.attach(contractAddress);

  // Check initial balance of deployer
  const [deployer] = await hre.ethers.getSigners();
  const balance = await token.balanceOf(deployer.address);
  console.log(`Initial Balance of Deployer: ${hre.ethers.utils.formatUnits(balance, 18)} MTK`);

  // Transfer tokens to another account
  const recipient = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"; // Replace with a valid address
  const transferAmount = hre.ethers.utils.parseUnits("1000", 18); // 1,000 MTK

  const tx = await token.transfer(recipient, transferAmount);
  await tx.wait();

  // Check balances after transfer
  const deployerBalance = await token.balanceOf(deployer.address);
  const recipientBalance = await token.balanceOf(recipient);
  console.log(`Deployer Balance: ${hre.ethers.utils.formatUnits(deployerBalance, 18)} MTK`);
  console.log(`Recipient Balance: ${hre.ethers.utils.formatUnits(recipientBalance, 18)} MTK`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });