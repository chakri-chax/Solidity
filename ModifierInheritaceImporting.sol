pragma solidity ^0.8.11;

contract OwnedParent
{
    address owner;

    constructor ()
    {
        owner = msg.sender;
    }

    modifier onlyOwner()
    {
        require(msg.sender == owner,"You are not allowed");
        _;
    }
}

contract InhertTransactionChild is OwnedParent
    {
        //send tokens
        //purchase tokens
        //create token
        //burn token
        mapping(address =>uint) public tokenBalance;
        uint tokenPrice = 1 ether;
        
        constructor() public
            {
                tokenBalance[owner] = 100;
            }

        
        function createToken() public onlyOwner
        {
            tokenBalance[owner]++;
        }

        function burnToken() public onlyOwner
        {
            tokenBalance[owner]--;
        }

        function purchaseToken() public payable
            {
                require(tokenBalance[owner]*tokenPrice/(msg.value) >= 0 ,"Not enough tokens");

                tokenBalance[owner] = tokenBalance[owner]-(msg.value/tokenPrice);
                tokenBalance[msg.sender] = tokenBalance[msg.sender]+(msg.value/tokenPrice);
                
            }

    }