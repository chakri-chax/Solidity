// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "./IDAO_DAO.sol";
import "./GovernanceToken.sol";
// import "./IProposals.sol";
import "hardhat/console.sol";

contract Proposal {
    address DaoAddress;
    uint256 proposalId;
    address creatorAddress;
    string proposalTitle;
    string proposalDescription;
    uint256 yesVotes;
    uint256 noVotes;
    uint256 abstainVotes;
    uint256 startTime;
    uint256 endTime;
    bool executed;
    bool approved;
    DAO.Action[] actions;
    DAO.Proposal DAOProposal;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    constructor(
        address _creator,
        string memory _title,
        string memory _description,
        // uint startTime; // For testing start time always block.timeStamp, we will modify later
        uint256 _duration,
        address _daoAddress,
        DAO.Action[] memory _actions
    ) {
        DaoAddress = _daoAddress;
        
        proposalTitle = _title;
        proposalDescription = _description;
        yesVotes = 0;
        noVotes = 0;
        abstainVotes = 0;
        startTime = block.timestamp;
        endTime = startTime + _duration;

        DAO daoInstance = DAO(DaoAddress);
        console.log("DAO Member Check: ", daoInstance.isDAOMember(msg.sender));
        console.log("msg.sender: ", msg.sender);
        uint256 minimumDuration = daoInstance.minimumDuration();
        require(endTime - startTime >= minimumDuration, "Invalid Timing");

        proposalId = daoInstance.proposalId();

        
        daoInstance.createProposal(_creator,_title, _description, _duration, _actions);

    }

    //  function voteOnProposal(uint256 _proposalId, uint8 _voteType) public {
    //      DAO daoInstance = DAO(DaoAddress);
    //      daoInstance.voteOnProposal(_proposalId, _voteType);
    //     }

    function voteOnProposal(uint256 _proposalId, uint8 _voteType) external {
        
        DAO daoInstance = DAO(DaoAddress);
        
        DAO.Proposal memory proposal = daoInstance.getProposal(_proposalId);
        proposal = daoInstance.getProposal(_proposalId);
        require(!proposal.executed, "Proposal already executed");
        require(!hasVoted[_proposalId][msg.sender], "You already voted");

        require(
            block.timestamp >= proposal.startTime,
            "Voting has not started yet"
        );
        require(_voteType <= 3, "Invalid vote type");
        require(block.timestamp <= proposal.endTime, "Voting has ended");
        hasVoted[_proposalId][msg.sender] = true;
        uint256 votes = daoInstance._getVotingUnits(msg.sender);
        require(votes > 0, "No voting power");
        console.log("user total votes", votes);

        daoInstance.updateVotes(_proposalId, _voteType);
        address daoGT = daoInstance.governanceTokenAddress();
        ERC20Votes erc20 = ERC20Votes(daoGT);
        uint256 totalSupply = erc20.totalSupply();
        uint256 supportPercentage = ((proposal.yesVotes * 100) / totalSupply);
        uint8 supportThresholdPercentage = daoInstance
            .supportThresholdPercentage();
        console.log("Total supply", totalSupply);
        console.log(
            "support thereshold",
            daoInstance.supportThresholdPercentage()
        );

        if (supportPercentage >= supportThresholdPercentage) {
            
            proposal.approved = true;
            console.log("Proposal approved id", _proposalId,proposal.approved,proposal.yesVotes);
        } else {
            proposal.approved = false;
            console.log("Proposal not approved id", _proposalId);
        }
    }

    function executeProposal_(uint256 _proposalId,address _executor) external  {
        DAO daoInstance = DAO(DaoAddress);
        DAO.Proposal memory proposal = daoInstance.getProposal(_proposalId);
        proposal = daoInstance.getProposal(_proposalId);
        console.log("Proposal details : ", _proposalId,proposal.approved,proposal.yesVotes);
        require(proposal.approved, "Proposal not yet approved");
        require(!proposal.executed, "Proposal already executed");
        daoInstance.executeProposal(_proposalId,_executor);
        proposal.executed = true;
    }
}
