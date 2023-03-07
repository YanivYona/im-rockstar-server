// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

//* *********************************************************************//
const baseName = "IMROCKSTAR";
const version = ""; // for example V2
const proxyAddress = "";
//* *********************************************************************//

async function main() {
  await beforeDeployment();

  console.log(
    `Upgrading to version ${version} over network: ${process.env.HARDHAT_NETWORK}`
  );

  const scName = baseName + version;
  const Rockers = await ethers.getContractFactory(scName);
  const rockers = await upgrades.upgradeProxy(proxyAddress, Rockers, {
    kind: "uups",
  });

  await rockers.deployed();
  console.log(`${baseName} upgraded to version ${version}`);
}

async function beforeDeployment() {
  if (!process.env.HARDHAT_NETWORK) {
    throw new Error("\n\n*******   Please define network   *******\n\n");
  }
  if (!version) {
    throw new Error("\n\n*******   Please define version   *******\n\n");
  }
  if (!proxyAddress) {
    throw new Error(
      "\n\n*******   Please define proxy contract address   *******\n\n"
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
