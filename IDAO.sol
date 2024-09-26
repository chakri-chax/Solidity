// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDAO {
    struct Proposal {
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
        Action[] actions;
    }

    struct Action {
        address to;
        uint256 value;
        bytes data;
    }

    function addDAOMembers(address[] memory addresses) external;

    function getProposal(uint256 _proposalId) external view returns (Proposal memory);

    function getAllProposals() external view returns (Proposal[] memory);

    function hasUserVoted(uint256 _proposalId, address account) external view returns (bool);

    function createProposal(
        address _creator,
        string memory _title,
        string memory _description,
        uint256 _duration,
        Action[] memory _actions
    ) external;
    function voteOnProposal(uint256 _proposalId, uint8 _voteType) external ;
    function executeProposal(uint256 _proposalId,address _executor) external;
    function _getVotingUnits(address _address) external view returns(uint256);
    function depositToDAOTreasury() external payable;

    function withdrawFromDAOTreasury(uint256 amount) external;

    function getDAOTreasuryBalance() external view returns (uint256);

    function getDAOMemberTreasuryBalance(address _address) external view returns (uint256);
}
