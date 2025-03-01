import { ethers, run } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying PiggyBankFactory with deployer: ${deployer.address}`);

  const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
  const USDT = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
  const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
  const developer = deployer.address;

  const PiggyBankFactory = await ethers.getContractFactory("PiggyBankFactory");
  const factory = await PiggyBankFactory.deploy(USDC, USDT, DAI, developer);

  await factory.waitForDeployment();
  const factoryAddress = await factory.getAddress();

  console.log(`PiggyBankFactory deployed to: ${factoryAddress}`);
  console.log(`🔗 View on Etherscan: https://sepolia.etherscan.io/address/${factoryAddress}`);

  console.log(`To manually verify the contract, use this command:`);
  console.log(`npx hardhat verify --network sepolia ${factoryAddress} ${USDC} ${USDT} ${DAI} ${developer}`);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  });



// import { ethers } from "hardhat";

// async function main() {
//   const [deployer] = await ethers.getSigners();

//   console.log(`Deploying PiggyBankFactory with deployer: ${deployer.address}`);

//   // Replace these with the actual stablecoin addresses on the network you're using
//   const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"; // Example USDC address
//   const USDT = "0xdAC17F958D2ee523a2206206994597C13D831ec7"; // Example USDT address
//   const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F"; // Example DAI address

//   const developer = deployer.address; // Using the deployer's address as developer

//   // Get the contract factory
//   const PiggyBankFactory = await ethers.getContractFactory("PiggyBankFactory");

//   // Deploy the factory contract
//   const factory = await PiggyBankFactory.deploy(USDC, USDT, DAI, developer);

//   // Wait for the contract deployment to be mined
//   await factory.waitForDeployment();

//   // Get deployed contract address
//   const factoryAddress = await factory.getAddress();

//   console.log(`PiggyBankFactory deployed to: ${factoryAddress}`);
// }

// // Execute deployment script
// main()
//   .then(() => process.exit(0))
//   .catch((error) => {
//     console.error("Deployment failed:", error);
//     process.exit(1);
//   });