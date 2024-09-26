// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "hardhat/console.sol";
import "./IDAO.sol";

contract DAO is IDAO {
    address public governanceTokenAddress;
    uint8 public minimumParticipationPercentage;
    uint8 public supportThresholdPercentage;
    uint256 public minimumDuration;
    bool public earlyExecution;
    bool public canVoteChange;
    bool public isMultiSignDAO;

    uint256 public proposalId;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public blacklisted;
    mapping(uint256 => bool) public isApproved;
    mapping(address => bool) public isDAOMember;
    mapping(address => uint256) public treasuryBalance;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    uint256 internal membersCount;

    modifier onlyDAO() {
        require(isDAOMember[msg.sender], "Not a DAO member");
        _;
    }

    modifier onlyApproved(uint256 id) {
        require(isApproved[id], "Proposal not approved");
        _;
    }

    modifier notBlacklisted(address account) {
        require(!blacklisted[account], "Address blacklisted");
        _;
    }

    modifier canInteractWithDAO() {
        require(isDAOMember[msg.sender], "Not a DAO Member");
        require(!blacklisted[msg.sender], "Address blacklisted");
        _;
    }

    constructor(
        address _governanceTokenAddress,
        uint8 _minimumParticipationPercentage,
        uint8 _supportThresholdPercentage,
        uint256 _minimumDurationForProposal,
        bool _earlyExecution,
        bool _canVoteChange,
        address[] memory _daoMembers,
        bool _isMultiSignDAO
    ) {
        governanceTokenAddress = _governanceTokenAddress;
        minimumParticipationPercentage = _minimumParticipationPercentage;
        supportThresholdPercentage = _supportThresholdPercentage;
        minimumDuration = _minimumDurationForProposal;
        earlyExecution = _earlyExecution;
        canVoteChange = _canVoteChange;
        isMultiSignDAO = _isMultiSignDAO;
        addDAOMembers(_daoMembers);
    }

    function addDAOMembers(address[] memory addresses) public override {
        for (uint256 i = 0; i < addresses.length; i++) {
            isDAOMember[addresses[i]] = true;
            membersCount++;
        }
    }

    function getProposal(uint256 _proposalId)
        public
        view
        override
        returns (Proposal memory)
    {
        return proposals[_proposalId];
    }

    function getAllProposals()
        public
        view
        override
        returns (Proposal[] memory)
    {
        Proposal[] memory proposalsArr = new Proposal[](proposalId);
        for (uint256 i = 0; i < proposalId; i++) {
            proposalsArr[i] = proposals[i];
        }
        return proposalsArr;
    }

    function hasUserVoted(uint256 _proposalId, address account)
        public
        view
        override
        returns (bool)
    {
        return hasVoted[_proposalId][account];
    }

    function createProposal(
        address _creator,
        string memory _title,
        string memory _description,
        uint256 _duration,
        Action[] memory _actions
    ) public override  {
        console.log("msg.sender",msg.sender);
        require(isDAOMember[_creator], "Not a DAO Member");
        uint256 _proposalId = proposalId++;
        Proposal storage newProposal = proposals[_proposalId];
        newProposal.creatorAddress = _creator;
        newProposal.proposalTitle = _title;
        newProposal.proposalDescription = _description;
        newProposal.startTime = block.timestamp;
        newProposal.endTime = block.timestamp + _duration;
        newProposal.executed = false;
        newProposal.approved = false;
        for (uint256 i = 0; i < _actions.length; i++) {
            newProposal.actions.push(_actions[i]);
        }
    }

    function _getVotingUnits(address account) public view returns (uint256) {
        ERC20Votes erc20 = ERC20Votes(governanceTokenAddress);
        return erc20.balanceOf(account);
    }

    function voteOnProposal(uint256 _proposalId, uint8 _voteType)
        public
        canInteractWithDAO
    {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(!hasVoted[_proposalId][msg.sender], "Already voted");
        require(
            block.timestamp >= proposal.startTime,
            "Voting has not started yet"
        );
        require(block.timestamp <= proposal.endTime, "Voting has ended");

        hasVoted[_proposalId][msg.sender] = true;
        uint256 votes = _getVotingUnits(msg.sender);
        require(votes > 0, "No voting power");
        console.log("user total votes", votes);
        if (_voteType == 1) {
            proposal.yesVotes += votes;
            console.log("Proposal yes votes", proposal.yesVotes);
        } else if (_voteType == 2) {
            proposal.noVotes += votes;
            console.log("Proposal no votes", proposal.noVotes);
        } else if (_voteType == 3) {
            proposal.abstainVotes += votes;
        } else {
            revert("Invalid vote type");
        }

        ERC20Votes erc20 = ERC20Votes(governanceTokenAddress);
        uint256 totalSupply = erc20.totalSupply();
        console.log("Total supply", totalSupply);
        console.log("support thereshold", supportThresholdPercentage);
        if ((votes * 100) / totalSupply >= supportThresholdPercentage) {
            if (earlyExecution && proposal.yesVotes > proposal.noVotes) {
                proposal.approved = true;
                console.log("Proposal approved id", _proposalId);
            } else {
                proposal.approved = false;
                console.log("Proposal not approved id", _proposalId);
            }
        } else {
            proposal.approved = false;
            console.log("Proposal not approved id", _proposalId);
        }
    }

    function updateVotes(uint256 _proposalId, uint256 _voteType) external  {
        Proposal storage proposal = proposals[_proposalId];
        if (_voteType == 1) {
            proposal.yesVotes += proposal.yesVotes ;
            
         } else if (_voteType == 3) {
            proposal.abstainVotes += proposal.abstainVotes ;
            
         } else if(_voteType ==2){
            proposal.noVotes += proposal.noVotes;
         }
    }

    

    function executeProposal(uint256 _proposalId,address _executor) public override  {
        require(isDAOMember[_executor],"Not a DAO member");
        Proposal storage proposal = proposals[_proposalId];
        for (uint256 i = 0; i < proposal.actions.length; i++) {
            Action memory action = proposal.actions[i];
            (bool success, ) = action.to.call{value: action.value}(action.data);
            require(success, "Action execution failed");
        }
    }
    function depositToDAOTreasury()
        external
        payable
        override
        canInteractWithDAO
    {
        require(msg.value > 0, "Send a value greater than zero!");
        treasuryBalance[msg.sender] += msg.value;
    }

    function withdrawFromDAOTreasury(uint256 amount)
        external
        override
        canInteractWithDAO
    {
        require(amount > 0, "Enter a valid amount!");
        require(treasuryBalance[msg.sender] >= amount, "Insufficient balance!");
        payable(msg.sender).transfer(amount);
        treasuryBalance[msg.sender] -= amount;
    }

    function getDAOTreasuryBalance() public view override returns (uint256) {
        return address(this).balance;
    }

    function getDAOMemberTreasuryBalance(address _address)
        public
        view
        override
        returns (uint256)
    {
        return treasuryBalance[_address];
    }


}
