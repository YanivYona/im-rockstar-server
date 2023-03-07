// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

//* *********************************************************************//
const baseName = "IMROCKSTAR";
const version = "V1"; // for example V1
//* *********************************************************************//

async function main() {
  await beforeDeployment();
  const owner = process.env.OWNER_ADDRESS;
  const signerAddress = process.env.SIGNER_ADDRESS;
  const royaltyReceiver = process.env.ROYALTY_RECEIVER;

  console.log(`Deploying to network: ${process.env.HARDHAT_NETWORK}`);

  const scName = baseName + version;
  const Rockers = await ethers.getContractFactory(scName);
  const rockers = await upgrades.deployProxy(
    Rockers,
    [owner, signerAddress, royaltyReceiver],
    {
      initializer: "initialize",
      kind: "uups",
    }
  );
  await rockers.deployed();
  console.log(`${baseName} deployed to: ${rockers.address}`);
}

async function beforeDeployment() {
  if (!process.env.HARDHAT_NETWORK) {
    throw new Error("\n\n*******   Please define network   *******\n\n");
  }
  if (!version) {
    throw new Error("\n\n*******   Please define version   *******\n\n");
  }
  if (!baseName) {
    throw new Error("\n\n*******   Please define base-name   *******\n\n");
  }
  if (!process.env.OWNER_ADDRESS) {
    throw new Error("\n\n*******   Please define Owner   *******\n\n");
  }
  if (!process.env.SIGNER_ADDRESS) {
    throw new Error("\n\n*******   Please define signer-address   *******\n\n");
  }
  if (!process.env.ROYALTY_RECEIVER) {
    throw new Error("\n\n*******   Please define signer-address   *******\n\n");
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
