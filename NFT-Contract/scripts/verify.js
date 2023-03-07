const hre = require("hardhat");
require("dotenv").config();

//* *********************************************************************//
const implementationContractAddress = "";
//* *********************************************************************//

async function main() {
  await beforeDeployment();

  console.log(`Verifying over network ${process.env.HARDHAT_NETWORK}...`);

  await hre.run("verify:verify", {
    address: implementationContractAddress,
  });

  console.log(
    `Contract is verified over network ${process.env.HARDHAT_NETWORK}`
  );
}

async function beforeDeployment() {
  if (!process.env.HARDHAT_NETWORK) {
    throw new Error("\n\n*******   Please define network   *******\n\n");
  }
  if (!implementationContractAddress) {
    throw new Error(
      "\n\n*******   Please define implementation contract address   *******\n\n"
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
