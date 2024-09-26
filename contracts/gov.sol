// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract GovernanceToken is ERC20, ERC20Burnable, ERC20Pausable, AccessControl {
    struct GovernanceToken {
        uint256 totalSupply;
        uint256 supportThreshold;
        uint256 minParticipants;
        uint256 votingDuration;
        uint256 rewardPercentage;
    }

    struct Proposal {
        uint id;
        address proposer;
        string description;
        uint votesFor;
        uint votesAgainst;
        bool executed;
        mapping(address => bool) voted;
    }

    mapping(uint => Proposal) public proposals;
    mapping(address => bool) public isTokenHolder;
    mapping(address => uint[]) public proposalsByOwner;
    mapping(address => address) public delegateMapping;
    mapping(address => uint256) public stakedAmount;

    uint public nextProposalId;
    address[] public tokenHolders;
    uint public quorum;

    event ProposalCreated(uint id, address indexed proposer, string description);
    event Voted(uint id, address indexed voter, bool support);
    event ProposalExecuted(uint id);
    event RewardDistributionSetup(uint rewardPercentage);
    event RewardsDistributed();
    event TokensStaked(address indexed staker, uint amount);
    event TokensUnstaked(address indexed staker, uint amount);
    event StakingRewardsDistributed();
    event QuorumAdjusted(uint newQuorum);
    event VotesDelegated(address indexed delegator, address indexed delegatee);

    bytes32 public constant TOKEN_HOLDER_ROLE = keccak256("TOKEN_HOLDER_ROLE");

    modifier onlyTokenHolder() {
        require(isTokenHolder[msg.sender], "Not a token holder");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 _supportThreshold,
        uint256 _minParticipants,
        uint256 _votingDuration
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        // Initialize governance token parameters
        GovernanceToken memory govToken = GovernanceToken(
            initialSupply,
            _supportThreshold,
            _minParticipants,
            _votingDuration,
            0
        );
    }

    // Define Membership
    function defineMembership(address[] calldata _addresses) external onlyTokenHolder {
        for (uint i = 0; i < _addresses.length; i++) {
            isTokenHolder[_addresses[i]] = true;
            tokenHolders.push(_addresses[i]);
        }
    }

    // Delegation Setup
    function delegateVotes(address _delegateTo) external onlyTokenHolder {
        require(_delegateTo != msg.sender, "Cannot delegate to yourself");
        delegateMapping[msg.sender] = _delegateTo;
        emit VotesDelegated(msg.sender, _delegateTo);
    }

    // Fetch Delegate
    function fetchDelegate(address _address) external view returns (address) {
        return delegateMapping[_address];
    }

    // Create Proposal
    function createProposal(string memory _description) external onlyTokenHolder {
        Proposal storage newProposal = proposals[nextProposalId];
        newProposal.id = nextProposalId;
        newProposal.proposer = msg.sender;
        newProposal.description = _description;
        newProposal.votesFor = 0;
        newProposal.votesAgainst = 0;
        newProposal.executed = false;

        proposalsByOwner[msg.sender].push(nextProposalId);
        nextProposalId++;

        emit ProposalCreated(newProposal.id, msg.sender, _description);
    }

    // Vote on Proposal
    function vote(uint _proposalId, bool support) external onlyTokenHolder {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.voted[msg.sender], "Already voted");

        proposal.voted[msg.sender] = true;

        if (support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        emit Voted(_proposalId, msg.sender, support);
    }

    // Execute Proposal
    function executeProposal(uint _proposalId) external {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp >= proposal.votesFor, "Voting period not ended");
        require(!proposal.executed, "Proposal already executed");

        if (proposal.votesFor >= quorum) {
            // Execute proposal logic (e.g., change governance parameters)
        }

        proposal.executed = true;
        emit ProposalExecuted(_proposalId);
    }

    // Fetch Proposal Details
    function fetchProposalDetails(uint _proposalId) external view returns (Proposal memory) {
        return proposals[_proposalId];
    }

    // Get Token Holders
    function getTokenHolders() external view returns (address[] memory) {
        return tokenHolders;
    }

    // Fetch My Proposals
    function fetchMyProposals() external view returns (uint[] memory) {
        return proposalsByOwner[msg.sender];
    }

    // Get Total Supply
    function getTotalSupply() external view returns (uint256) {
        return totalSupply();
    }

    // Get Remaining Votes for Proposal
    function getRemainingVotes(uint _proposalId) external view returns (uint) {
        Proposal storage proposal = proposals[_proposalId];
        return (proposal.votesFor + proposal.votesAgainst) < quorum
            ? 0
            : quorum - (proposal.votesFor + proposal.votesAgainst);
    }

    // Check if Address is Token Holder
    function isAddressTokenHolder(address _address) external view returns (bool) {
        return isTokenHolder[_address];
    }

    // Mint Tokens
    function mint(address _to, uint256 _amount) external onlyTokenHolder {
        _mint(_to, _amount);
    }

    // Burn Tokens
    function burn(uint256 _amount) external override onlyTokenHolder {
        _burn(msg.sender, _amount);
    }

    // Reward Distribution
    function setupRewardDistribution(uint _rewardPercentage) external onlyTokenHolder {
        require(_rewardPercentage > 0 && _rewardPercentage <= 100, "Invalid reward percentage");
        emit RewardDistributionSetup(_rewardPercentage);
    }

    function distributeRewards() external onlyTokenHolder {
        // Implement reward distribution logic
        emit RewardsDistributed();
    }

    // Staking Mechanism
    function stakeTokens(uint _amount) external onlyTokenHolder {
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance");
        _transfer(msg.sender, address(this), _amount);
        stakedAmount[msg.sender] += _amount;
        emit TokensStaked(msg.sender, _amount);
    }

    function unstakeTokens(uint _amount) external onlyTokenHolder {
        require(stakedAmount[msg.sender] >= _amount, "Insufficient staked amount");
        stakedAmount[msg.sender] -= _amount;
        _transfer(address(this), msg.sender, _amount);
        emit TokensUnstaked(msg.sender, _amount);
    }

    function distributeStakingRewards() external onlyTokenHolder {
        // Implement staking rewards distribution logic
        emit StakingRewardsDistributed();
    }

    // Quorum Adjustments
    function adjustQuorum(uint _newQuorum) external onlyTokenHolder {
        require(_newQuorum > 0 && _newQuorum <= 100, "Invalid quorum percentage");
        quorum = _newQuorum;
        emit QuorumAdjusted(_newQuorum);
    }
}
