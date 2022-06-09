pragma solidity ^0.8.10;

contract CM_Voting
    {
        address owner;
        uint TDP_vote;
        uint YSRCP_vote;
        uint JanaSena_vote;

        uint totalVotes;

        constructor() public
            {
                owner = msg.sender;
            }

        struct authorizing
            {
                bool authorized;
                bool voted;
                
            }
            mapping(address => authorizing)voter;

        modifier isOwner
            {
                require(owner == msg.sender,"Your not owner");
                _;
            }

        function authorization(address _voterAdrs) isOwner public
            {
                voter[_voterAdrs].authorized = true;
            }

        function VoteFor_TDP(address _voterAddress) public
            {
                require(!voter[_voterAddress].voted,"you already voted");
                require(voter[_voterAddress].authorized,"Your not authorized");

                voter[_voterAddress].voted = true;

                TDP_vote++;
                totalVotes++;

            }
        function VoteFor_YSRCP(address _voterAddress) public
            {
                require(!voter[_voterAddress].voted,"you already voted");
                require(voter[_voterAddress].authorized,"Your not authorized");

                voter[_voterAddress].voted = true;

                YSRCP_vote++;
                totalVotes++;


            }
        function VoteFor_JanaSena(address _voterAddress) public
            {
                require(!voter[_voterAddress].voted,"you already voted");
                require(voter[_voterAddress].authorized,"Your not authorized");

                voter[_voterAddress].voted = true;

                JanaSena_vote++;
                totalVotes++;
            }

        function TotalVotes() public view returns(uint)
            {
                return totalVotes;
            }


        function Winner() public view returns(string memory)
            {
                if(TDP_vote > YSRCP_vote)
                    {
                        if(TDP_vote > JanaSena_vote)
                            {
                                return "TDP Won....";
                            }
                        else if(JanaSena_vote > TDP_vote)
                            {
                                return "JanaSena Won....";
                            }
                else if (YSRCP_vote > JanaSena_vote && YSRCP_vote > TDP_vote)      
                    {
                        return "YSRCP Won......";
                    } 
                else if (TDP_vote == YSRCP_vote && TDP_vote == JanaSena_vote || JanaSena_vote ==YSRCP_vote)
                    {
                        return "No one is Won.... ";
                    }                         
                    }

            }

    }