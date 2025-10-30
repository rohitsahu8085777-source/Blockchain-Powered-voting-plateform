// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Blockchain Powered Voting Platform
/// @notice A decentralized voting system allowing transparent and secure elections on the blockchain.
contract Project {
    address public admin;
    bool public votingStarted;
    bool public votingEnded;

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public hasVoted;
    uint public candidatesCount;

    event CandidateAdded(uint id, string name);
    event VoteCasted(address voter, uint candidateId);
    event VotingStarted();
    event VotingEnded();

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier duringVoting() {
        require(votingStarted && !votingEnded, "Voting is not active");
        _;
    }

    // Add a candidate (only admin)
    function addCandidate(string memory _name) public onlyAdmin {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }

    // Start voting (only admin)
    function startVoting() public onlyAdmin {
        require(!votingStarted, "Voting already started");
        votingStarted = true;
        emit VotingStarted();
    }

    // Cast a vote (any user)
    function vote(uint _candidateId) public duringVoting {
        require(!hasVoted[msg.sender], "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");
        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        emit VoteCasted(msg.sender, _candidateId);
    }

    // End voting (only admin)
    function endVoting() public onlyAdmin {
        require(votingStarted && !votingEnded, "Voting not started or already ended");
        votingEnded = true;
        emit VotingEnded();
    }

    // Get winner (any user)
    function getWinner() public view returns (string memory winnerName, uint winnerVotes) {
        require(votingEnded, "Voting not yet ended");
        uint winningVoteCount = 0;
        uint winningCandidateId = 0;

        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }

        winnerName = candidates[winningCandidateId].name;
        winnerVotes = candidates[winningCandidateId].voteCount;
    }
}

