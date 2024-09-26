// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DAO.sol";
import "./GovernanceToken.sol";

contract DAOFactory {
    
    struct DAOInfo {
        string name;
        address daoAddress;
        address governanceAddress;
    }
    struct GovernanceTokenSet{
        string name;
        string symbol;
        uint256 initialSupply;
        address initialAddress;
        uint8 decimals;
    }

    uint256 public daoId;
    mapping(uint256 => DAOInfo) public daos;
    GovernanceToken.smartContractActions actions;

    function createDAO(
        string memory daoName,
        address governanceTokenAddress,
        uint8 minimumParticipationPercentage,
        uint8 supportThresholdPercentage,
        uint256 minimumDuration,
        bool earlyExecution,
        bool canVoteChange,
        address[] memory _daoMembers,
        bool isMultiSignDAO,
        bool havingGovernanceToken,
       GovernanceToken memory GTInputs,
        GovernanceToken.smartContractActions memory _actions
    ) public {
        address newGt;
        if (!havingGovernanceToken) {
            // Create a new governance token
            GovernanceToken GT = new GovernanceToken(GTInputs.name, GTInputs.symbol, GTInputs.initialSupply, GTInputs._initialAddress, GTInputs.decimals, _actions);
            newGt = address(GT);
        } else {
            newGt = governanceTokenAddress;
        }
        
        DAO newDAO = new DAO(
            newGt,
            minimumParticipationPercentage,
            supportThresholdPercentage,
            minimumDuration,
            earlyExecution,
            canVoteChange,
            _daoMembers,
            isMultiSignDAO
        );

        appendToFactory(daoName, address(newDAO), newGt);
        daoId++;
    }

    function appendToFactory(
        string memory _name,
        address _dao,
        address _governance
    ) internal returns (bool) {
        DAOInfo storage dao = daos[daoId];
        dao.name = _name;
        dao.daoAddress = _dao;
        dao.governanceAddress = _governance;
        return true;
    }

    function getAllDaos() public view returns (DAOInfo[] memory) {
        DAOInfo[] memory allDaos = new DAOInfo[](daoId);

        for (uint256 i = 0; i < daoId; i++) {
            allDaos[i] = daos[i];
        }

        return allDaos;
    }
}
