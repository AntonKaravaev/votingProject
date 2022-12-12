async function main() {
    const votingProject = await ethers.getContractFactory("VotingProject");
 
    // Start deployment, returning a promise that resolves to a contract object
    const voting_project = await votingProject.deploy("VotingProject!");   
    console.log("Contract deployed to address:", voting_project.address);
 }
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
   });