//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract VotingProject {
    address private owner;
    uint256 private votingCounter = 0;
    uint256 private candidatesCounter = 0;

    mapping(uint256 => VotingEntity) private idToVotingMap;
    mapping(uint256 => address) private idVotingToCreatorMap;
    mapping(uint256 => Candidate) private IdCandidateToCandidateMap;
    mapping(address => Voter) private voterAddrToVoterMap;


    enum TypeOfVoting {
        PUBLIC_VOTING,
        ANONYM_VOTING
    }

    enum StagesOfVoting {
        CREATED,
        STARTED,
        FINISHED
    }

    event DeployedOwnerEvent(address ownerAddress);
    event AddAnVotingEvent(address creator, string votingName, uint256 id);
    event RemoveVotingEvent(uint256 votingId);
    event AddCandidateEvent(uint256 votingId, string nameCandidate);
    event RemoveCandidateEvent(uint256 candidateId);
    event StartVotingEvent(
        StagesOfVoting stagesOfVoting,
        uint256 startTime,
        uint256 finishTime
    );
    event ToVoteEvent(
        uint256 candidateId,
        address voterAddr,
        uint256 candidateVoteCounter
    );

    event RecalculationPositionsEvent(Candidate[] candidates);

    constructor() {
        owner = msg.sender;
        emit DeployedOwnerEvent(owner);
    }

    modifier onlyCreator(uint256 _votingId) {
        require(
            idVotingToCreatorMap[_votingId] == msg.sender,
            "Not a creator of this voting"
        );
        _;
    }

    modifier checkStagesOfVotingCREATED(uint256 _votingId) {
        require(
            idToVotingMap[_votingId].stagesOfVoting == StagesOfVoting.CREATED,
            "Voting has to be in stage CREATED"
        );
        _;
    }

    modifier checkStagesOfVotingSTARTED(uint256 _votingId) {
        require(
            idToVotingMap[_votingId].stagesOfVoting == StagesOfVoting.STARTED,
            "Voting has to be in stage STARTED"
        );
        _;
    }

    modifier checkEndTime(uint256 _votingId) {
        require(
            block.timestamp < idToVotingMap[_votingId].finishVotingTime,
            "Time of voting has been finished"
        );
        _;
    }

     modifier checkItsFirstVoting() {
        require(
            voterAddrToVoterMap[msg.sender].voted == false,
            "It is not the first voting of this voter"
        );
        _;
    }

    struct Candidate {
        string name;
        uint256 id;
        uint256 voteCounter;
    }

    struct Voter {
        uint candidateId;
        bool voted;
    }

    struct VotingEntity {
        string name;
        uint256 id;
        TypeOfVoting votingType;
        StagesOfVoting stagesOfVoting;
        address owner;
        uint256 startVotingTime;
        uint256 finishVotingTime;
    }

    function createVoting(string memory _nameVoting, TypeOfVoting _votingType)
        public
        returns (uint256)
    {
        idVotingToCreatorMap[votingCounter] = msg.sender;
        idToVotingMap[votingCounter] = VotingEntity(
            _nameVoting,
            votingCounter,
            _votingType,
            StagesOfVoting.CREATED,
            msg.sender,
            0,
            0
        );

        emit AddAnVotingEvent(msg.sender, _nameVoting, votingCounter);
        return votingCounter++;
    }

    function addCandidate(uint256 _votingId, string memory _nameCandidate)
        public
        onlyCreator(_votingId)
        checkStagesOfVotingCREATED(_votingId)
        returns (uint256)
    {

        IdCandidateToCandidateMap[candidatesCounter] = Candidate(_nameCandidate, candidatesCounter, 0);
        emit AddCandidateEvent(_votingId, _nameCandidate);
        return candidatesCounter++;
    }

    function removeCandidate(uint256 _votingId, uint256 _candidateId)
        public
        onlyCreator(_votingId)
        checkStagesOfVotingCREATED(_votingId)
        returns (bool)
    {
        delete IdCandidateToCandidateMap[_candidateId];
        emit RemoveCandidateEvent(_candidateId);
        return true;
    }

    function startVoting(uint256 _votingId, uint256 finishTime)
        public
        onlyCreator(_votingId)
        checkStagesOfVotingCREATED(_votingId)
        returns (bool)
    {
        idToVotingMap[_votingId].stagesOfVoting = StagesOfVoting.STARTED;
        idToVotingMap[_votingId].startVotingTime = block.timestamp;
        idToVotingMap[_votingId].finishVotingTime =
            block.timestamp +
            finishTime;
        emit StartVotingEvent(
            StagesOfVoting.STARTED,
            idToVotingMap[_votingId].startVotingTime,
            idToVotingMap[_votingId].finishVotingTime
        );
        return true;
    }

    function toVote(uint256 _votingId, uint256 _candidateId)
        public
        checkStagesOfVotingSTARTED(_votingId)
        checkEndTime(_votingId)
        checkItsFirstVoting()
        returns (bool)
    {
        
        voterAddrToVoterMap[msg.sender] = Voter(_candidateId, true);
        IdCandidateToCandidateMap[_candidateId].voteCounter += 1;
        emit ToVoteEvent(
            _candidateId,
            msg.sender,
            IdCandidateToCandidateMap[_candidateId].voteCounter
        );
        return (true);
    }

    function finishVoting(uint256 _votingId)
        public
        checkStagesOfVotingSTARTED(_votingId)
        returns (bool)
    {
        idToVotingMap[_votingId].stagesOfVoting = StagesOfVoting.FINISHED;
        return true;
    }

    function removeVoting(uint256 _votingId)
        public
        checkStagesOfVotingCREATED(_votingId)
        onlyCreator(_votingId)
        returns (bool)
    {
        delete idToVotingMap[_votingId];
        delete idVotingToCreatorMap[_votingId];
        emit RemoveVotingEvent(_votingId);
        return true;
    }
}
