// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface Iproposals {
    
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
    }
    
}