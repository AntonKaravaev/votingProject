const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;

const contract = require("../artifacts/contracts/VotingProject.sol/VotingProject.json");

// Provider
const alchemyProvider = new ethers.providers.AlchemyProvider(network="goerli", API_KEY);

// Signer
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);

// Contract
const votingContract = new ethers.Contract(CONTRACT_ADDRESS, contract.abi, signer);

// // npx hardhat run scripts/interact.js 
async function main() {
    const message = await votingContract.createVoting("testVoting", 0);
    console.log(message);
    
    const candidateAns = await votingContract.addCandidate(message.value, "testCandidate");
    console.dir(candidateAns);
   
}

async function loggingInfo() {
    console.dir(alchemyProvider);
    console.dir(votingContract);
    console.dir(signer);
}

main();

