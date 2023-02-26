//SPDX-License-Identifier:MIT
pragma solidity ^0.8.6;

contract A
    { 
        
          //Reentrancy is a destructive attack carried out by the other malicious account (contract B)
        //that withdraws the entire balance at once from the Staked_contract account(contract A). 


        bool internal locked;
        mapping (address=>uint) public balance;

        function deposit() public payable
            {
                balance[msg.sender] += msg.value;
            }

        function withdraw() public nonReentrant
            {
                uint bal = balance[msg.sender];
                (bool sent,) = msg.sender.call{value:bal} ("");
                require (sent,"failure");
                balance[msg.sender] = 0;

            }
        function getbalance() public view returns(uint)
            {
                return address(this).balance;
            }
        
        // This modifier protects the amount of your contract from a malicious contract attack.
        // This modifier prevents the other malicious contract from entering a stake contract again. 

        modifier nonReentrant() //ReEntrancy guard
            {
                require(!locked,"No Reentrancy");
                locked = true;

                _;
                locked = false;
            }
    }

contract B //malicious account
    {
        A public a;
        constructor (address _aAddress)
            {
                a = A(_aAddress); //instance of a contract A.
            }

            fallback() external payable
                {
                    if(address(a).balance >= 1 ether)
                        {
                            a.withdraw();
                        }
                }
            function attack() external payable
                {
                    require(msg.value>=1 ether);
                    a.deposit{value:1 ether}();
                    a.withdraw();
                }

            function getbalance() public view returns(uint)
                {
                    return address(this).balance;
                }


            // function deposit() public payable
            //     {
            //         a.deposit{value:1 ether}();
            //     }
            // function withdraw() external payable
            //     {
            //         a.withdraw();
            //     }
                
    }
