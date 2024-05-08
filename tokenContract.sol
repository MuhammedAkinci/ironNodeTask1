// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ironNodeToken is ERC20 {
    struct Proposal {
        uint256 id;
        string description;
        uint256 votes;
        bool executed;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;

    event Vote(address indexed voter, uint256 indexed proposalId, bool support);
    event ProposalCreated(uint256 indexed proposalId, string description);

    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    function createProposal(string memory description) public {
        proposalCount++;
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.id = proposalCount;
        newProposal.description = description;
        newProposal.votes = 0;
        newProposal.executed = false;
        emit ProposalCreated(proposalCount, description);
    }

    function vote(uint256 proposalId, bool support) public {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Invalid proposal");

        if (support) {
            proposal.votes++;
        } else {
            proposal.votes--;
        }
        emit Vote(msg.sender, proposalId, support);
    }

    function checkProposalResult(uint256 proposalId) public {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Invalid proposal");

        if (proposal.votes > 0) {
            proposal.executed = true;
        } else {
            proposal.executed = false;
        }
    }
}
