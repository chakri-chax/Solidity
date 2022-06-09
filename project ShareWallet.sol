pragma solidity ^0.8.11;

contract ownable
    {
        mapping(address=>uint) public allowance;
        address owner;

        constructor() public 
        { 
             owner = msg.sender;
        }  

        function isOwner() internal view returns(bool) 
            {
                return msg.sender==owner;
            }
        modifier onlyOwner()
            {
                require(owner==msg.sender,"You are not allowed");
                _;
            }

        function setAllowance(address _who,uint _amount) public onlyOwner
            {
            allowance[_who] = _amount;
            }

        modifier ownerOrAllowed(uint _amount)
            {
                require(isOwner() || (allowance[msg.sender] >= _amount),"recognizaion failed");
                _;
            }
    }
