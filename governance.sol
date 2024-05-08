// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract governance is ERC20, Ownable {

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
    }

    enum ProposalState { Pending, Active, Defeated, Succeeded, Executed }

    uint256 public proposalCount;

    mapping(uint256 => Proposal) public proposals;

    mapping(address => uint256) public votes;

    mapping(address => bool) public voted;

    event Vote(address indexed voter, uint256 indexed proposalId, bool support);

    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description);

    constructor(string memory name, string memory symbol, uint256 initialSupply, address initialOwner) ERC20(name, symbol) Ownable(initialOwner) {
        _mint(initialOwner, initialSupply);
    }

    function createProposal(string memory description) public {
        require(balanceOf(msg.sender) > 0, "Must have tokens to create a proposal");

        uint256 newProposalId = ++proposalCount;

        Proposal storage newProposal = proposals[newProposalId];

        newProposal.id = newProposalId;
        newProposal.proposer = msg.sender;
        newProposal.description = description;
        newProposal.forVotes = 0;
        newProposal.againstVotes = 0;
        newProposal.executed = false;

        emit ProposalCreated(newProposalId, msg.sender, description);
    }

    function vote(uint256 proposalId, bool support) public {
        require(balanceOf(msg.sender) > 0, "Must have tokens to vote");

        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Invalid proposal");

        require(!voted[msg.sender], "Already voted");

        if (support) {
            proposal.forVotes += balanceOf(msg.sender);
        } else {
            proposal.againstVotes += balanceOf(msg.sender);
        }

        votes[msg.sender] = proposalId;
        voted[msg.sender] = true;

        emit Vote(msg.sender, proposalId, support);
    }

    function checkProposalResult(uint256 proposalId) public onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Invalid proposal");

        require(!proposal.executed, "Proposal already executed");

        if (proposal.forVotes > proposal.againstVotes) {
            proposal.executed = true;
        } else {
            proposal.executed = false;
        }
    }
}
