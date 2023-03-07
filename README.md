![alt text](<./snippets/Rockers-logo.PNG>)

## Description

The project includes:
- An [ERC721](https://eips.ethereum.org/EIPS/eip-721) based NFT smart contract that supports a presale based on a predefined whitelist 
and a public sale.
- A service that is able to produce a signature over a given address
  in case it is whitelisted.

## About the Smart-Contract
- Signature based whitelist
- Based on [721A standard](https://www.azuki.com/erc721a)
- Upgradeable using [UUPS pattern](https://eips.ethereum.org/EIPS/eip-1822)
- Supports [2981 royalties standard](https://eips.ethereum.org/EIPS/eip-2981)

## About the Signer
A service that is able to produce a signature over a given address
in case it is whitelisted.

## Installation

```bash
$ npm install
```

## Environment Variables
The root folder should contain a `.env` file with the property `SIGNER_KEY` 

## Running

```bash
# development
$ npm run start

# watch mode
$ npm run start:dev

# production mode
$ npm run start:prod
```
