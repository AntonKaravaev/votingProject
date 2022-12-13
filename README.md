# votingProject
Decentralised project about online voting

1: Connect to the Ethereum network
https://www.alchemy.com/

2: Create your app (and API key)
Navigate to the “Create App” page in your Alchemy Dashboard by hovering over “Apps” in the nav bar and clicking “Create App”.

3: Create an Ethereum account (address)
Metamask

4: Add ether from a Faucet
https://goerlifaucet.com/

5: Initialize our project

mkdir project
cd project

mkdir hello-world
cd hello-world

npm init (and enter several times)

6: Download Hardhat
npm install --save-dev hardhat

7: Create a Hardhat project
npx hardhat
Select “create an empty hardhat.config.js”

8: Add project folders
mkdir contracts
mkdir scripts

- `contracts/` is where we’ll keep our hello world smart contract code file
- `scripts/` is where we’ll keep scripts to deploy and interact with our contract

9: Write a contract

10: Connect Metamask & Alchemy to your project
npm install dotenv --save

in .env add fhree parametrs API_URL, PRIVATE_KEY, ETHERSCAN_API_KEY

11: Install Ethers.js
npm install --save-dev @nomiclabs/hardhat-ethers "ethers@^5.0.0"

12: Update hardhat.config.js (as in this project)

13: Compile our contract
npx hardhat compile

14: Write our deploy script
Navigate to the scripts/ folder and create a new file called deploy.js

15: Deploy our contract
npx hardhat run scripts/deploy.js --network goerli
Contract deployed to address: 0x"address"