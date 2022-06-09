pragma solidity ^0.8.13;

contract Lottery
    {
        address public manager;
        address payable[] public participants;

        constructor()
            {
                manager = msg.sender;
            }

        receive() external payable
            {
                require(msg.value == 0.1 ether);
                participants.push(payable(msg.sender));//push=>append : like list appending 
                                                        //in python
                

            }
        function getBalance() public view returns(uint)
            {
                require(msg.sender==manager);
                return address(this).balance;
            }

        function randomNum() public view returns(uint)
            {
                return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,participants.length)));
            }
        function selectWinner() public
            {
                require(msg.sender == manager);
                require(participants.length >=3);

                address payable winner;
                uint r = randomNum();
                uint index = r%participants.length;
                winner = participants[index];
                winner.transfer(getBalance());
                participants = new address payable[](0);

            }
    }