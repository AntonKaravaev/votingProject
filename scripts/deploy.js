async function main() {
    const Voting = await ethers.getContractFactory("Voting");
 
    // Start deployment, returning a promise that resolves to a contract object
    const voting_project = await Voting.deploy();   
    console.log("Contract deployed to address:", voting_project.address);
 }
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
   });