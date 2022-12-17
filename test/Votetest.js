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

var assert = require('assert');

async function createVoting() {
    const votingObject = await votingContract.createVoting("testVoting", 0);
    return votingObject.value;
}

describe("Check adding voting", function () {
  it("Check adding voting", async function () {
    let votingId = createVoting()

    votingId.then(function(id){
        console.log("eqweqwe", id)
        assert(id == 0)
    })
  })
});

describe("Add a candidate", function () {
    it("Add a candidate", async function () {
      const candidateObject = await votingContract.addCandidate(0, "candidateTest")
      let candidateId = candidateObject.value
      console.log("candidateId = ", candidateId)
      assert(candidateId == 0)
    })
});

describe("Remove voting", function () {
    it("Remove voting", async function () {
        const votingRemoveObject = await votingContract.removeVoting(0)
        let votingRemove = votingRemoveObject.value
        console.log("votingRemove = ", votingRemove)
        assert(votingRemove == true)
    })
});