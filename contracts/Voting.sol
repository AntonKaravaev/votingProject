pragma solidity ^0.8.7;

contract Login {
    address private owner;
    uint private votingCounter = 0;
    uint private candidatesCounter = 0;
    uint private voterCounter = 0;

    mapping(uint => Voting) private idToVotingMap;
    mapping(uint => address) private idVotingToCreatorMap;

    mapping(uint => Candidate[]) private votingIdToCandidatesMap;
    mapping(uint => Candidate) private IdCandidateToCandidateMap;

    mapping(uint => Voter[]) private votingIdToVotersMap;
    mapping(uint => Voter) private voterIdToVoterMap;

    mapping(uint => uint) private candidateAndPosition;

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
    event RemoveVotingEvent(uint votingId);
    event AddCandidateEvent(uint votingId, string nameCandidate);
    event RemoveCandidateEvent(uint candidateId);
    event StartVotingEvent(
        StagesOfVoting stagesOfVoting,
        uint startTime,
        uint finishTime
    );
    event ToVoteEvent(
        uint candidateId,
        uint voterId,
        uint candidateVoteCounter
    );

    constructor(address _owner) {
        owner = _owner;
        emit DeployedOwnerEvent(owner);
    }

    modifier onlyCreator(uint256 _id) {
        require(
            idVotingToCreatorMap[_id] == msg.sender,
            "Not a creator of this voting"
        );
        _;
    }

    modifier checkStagesOfVotingCREATED(uint _votingId) {
        require(
            idToVotingMap[_votingId].stagesOfVoting == StagesOfVoting.CREATED,
            "Voting has to be in stage CREATED"
        );
        _;
    }

    modifier checkStagesOfVotingSTARTED(uint _votingId) {
        require(
            idToVotingMap[_votingId].stagesOfVoting == StagesOfVoting.STARTED,
            "Voting has to be in stage STARTED"
        );
        _;
    }

    modifier checkEndTime(uint _votingId) {
        require(
            idToVotingMap[_votingId].finishVotingTime < block.timestamp,
            "Time of voting has been finished"
        );
        _;
    }

    struct Voting {
        string name;
        uint256 id;
        TypeOfVoting votingType;
        StagesOfVoting stagesOfVoting;
        address owner;
        uint256 startVotingTime;
        uint256 finishVotingTime;
    }

    struct Candidate {
        string name;
        uint256 id;
        uint256 voteCounter;
        uint256 position;
    }

    struct Voter {
        address voterAddress;
        uint voterId;
        bool voted;
    }

    function createVoting(
        string memory _nameVoting,
        TypeOfVoting _votingType
    ) public returns (uint) {
        idVotingToCreatorMap[votingCounter] = msg.sender;
        idToVotingMap[votingCounter] = Voting(
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

    function addCandidate(
        uint _votingId,
        string memory _nameCandidate
    )
        public
        onlyCreator(_votingId)
        checkStagesOfVotingCREATED(_votingId)
        returns (uint)
    {
        checkDuplicatesCandidates(
            votingIdToCandidatesMap[_votingId],
            _nameCandidate
        );
        votingIdToCandidatesMap[_votingId][candidatesCounter] = Candidate(
            _nameCandidate,
            candidatesCounter,
            0,
            0
        );
        emit AddCandidateEvent(_votingId, _nameCandidate);
        return candidatesCounter++;
    }

    function checkDuplicatesCandidates(
        Candidate[] memory _candidates,
        string memory nameCandidate
    ) private {
        uint amountOfCandidates = _candidates.length;
        for (uint i = 0; i < amountOfCandidates; i++) {
            require(
                keccak256(abi.encodePacked((_candidates[i].name))) !=
                    keccak256(abi.encodePacked((nameCandidate))),
                "You can't add the same candidate twice"
            );
        }
    }

    function removeCandidate(
        uint _votingId,
        uint _candidateId
    ) public onlyCreator(_votingId) checkStagesOfVotingCREATED(_votingId) {
        delete votingIdToCandidatesMap[_votingId][_candidateId];
        delete IdCandidateToCandidateMap[_candidateId];
        emit RemoveCandidateEvent(_candidateId);
    }

    function startVoting(
        uint _votingId,
        uint finishTime
    ) public onlyCreator(_votingId) checkStagesOfVotingCREATED(_votingId) {
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
    }

    function toVote(
        uint _votingId,
        uint _candidateId
    )
        public
        checkStagesOfVotingSTARTED(_votingId)
        checkEndTime(_votingId)
        returns (Candidate[] memory, uint)
    {
        votingIdToVotersMap[_votingId][voterCounter] = Voter(
            msg.sender,
            voterCounter,
            true
        );
        voterIdToVoterMap[voterCounter] = Voter(msg.sender, voterCounter, true);
        IdCandidateToCandidateMap[_candidateId].voteCounter += 1;
        Candidate[] memory candidates = recalculatePosition(_votingId);
        emit ToVoteEvent(
            _candidateId,
            voterCounter,
            IdCandidateToCandidateMap[_candidateId].voteCounter
        );
        voterCounter++;
        return (candidates, voterCounter - 1);
    }

    function recalculatePosition(
        uint _votingId
    ) private returns (Candidate[] memory) {
        Candidate[] memory candidates = votingIdToCandidatesMap[_votingId];

        for (uint i = 0; i < candidates.length; i++) {
            for (uint j = i + 1; j < candidates.length; j++) {
                if (candidates[i].voteCounter < candidates[j].voteCounter) {
                    Candidate memory tempCandidate = candidates[i];
                    candidates[i] = candidates[j];
                    candidates[j] = tempCandidate;
                }
            }
        }

        candidates[0].position = 1;
        uint tempPosition = 1;
        for (uint i = 1; i < candidates.length; i++) {
            if (candidates[i].voteCounter == candidates[i - 1].voteCounter) {
                candidates[i].position = tempPosition;
            } else {
                tempPosition++;
                candidates[i].position = tempPosition;
            }
        }
        return candidates;
    }

    function finishVoting(
        uint _votingId
    )
        public
        checkStagesOfVotingSTARTED(_votingId)
        returns (Candidate[] memory)
    {
        idToVotingMap[_votingId].stagesOfVoting = StagesOfVoting.FINISHED;
        return recalculatePosition(_votingId);
    }

    function removeVoting(
        uint _votingId
    ) public checkStagesOfVotingCREATED(_votingId) {
        delete idToVotingMap[_votingId];
        delete idVotingToCreatorMap[_votingId];
        emit RemoveVotingEvent(_votingId);
    }
}
