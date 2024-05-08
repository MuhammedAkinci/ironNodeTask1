// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceToken is ERC20, Ownable {
    // Öneri yapısı
    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
    }

    // Öneri durumları
    enum ProposalState { Pending, Active, Defeated, Succeeded, Executed }

    // Öneri ID'leri
    uint256 public proposalCount;

    // Öneri listesi
    mapping(uint256 => Proposal) public proposals;

    // Token sahiplerinin oyları
    mapping(address => uint256) public votes;

    // Oy kullanan token sahipleri
    mapping(address => bool) public voted;

    // Oylama sonuçları
    event Vote(address indexed voter, uint256 indexed proposalId, bool support);
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description);

    constructor(string memory name, string memory symbol, uint256 initialSupply, address initialOwner) ERC20(name, symbol) Ownable(initialOwner) {
        _mint(msg.sender, initialSupply);
    }

    // Yeni bir öneri oluştur
    function createProposal(string memory description) external {
        require(balanceOf(msg.sender) > 0, "Must have tokens to create a proposal");
        uint256 proposalId = ++proposalCount;
        Proposal storage newProposal = proposals[proposalId];
        newProposal.id = proposalId;
        newProposal.proposer = msg.sender;
        newProposal.description = description;
        newProposal.forVotes = 0;
        newProposal.againstVotes = 0;
        newProposal.executed = false;
        emit ProposalCreated(proposalId, msg.sender, description);
    }

    // Öneriye oy ver
    function vote(uint256 proposalId, bool support) external {
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

    // Öneri oylarının sonuçlarını kontrol et
    function checkProposalResult(uint256 proposalId) external onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Invalid proposal");
        require(!proposal.executed, "Proposal already executed");
        if (proposal.forVotes > proposal.againstVotes) {
            proposal.executed = true;
            // Öneri başarılı oldu, burada yapılacak işlemi belirtin
        } else {
            // Öneri başarısız oldu, burada yapılacak işlemi belirtin
        }
    }
}
