pragma solidity ^0.8.11;

//burn Token
//create Token
//purchase Token
//send Token

contract owned
    {
        address owner;

        constructor() public
            {
                owner = msg.sender;
            }

    modifier onlyOwner()
        {
            require(msg.sender==owner,"You are not allowed...!");
            _;
        }

    }
    contract InhertClassModifierWithTokenBalance is owned
        {
            mapping(address=>uint) public tokenBalance;
            uint tokenPrice=1 ether;
            
            constructor() public
                {  
                    tokenBalance[owner] = 100;
                }
        /* function getBal() public view returns(uint)
            {
                return tokenBalance[owner];
            }
         */
            function burnToken() public onlyOwner
                {
                    tokenBalance[owner]--;
                }

            function createToken() public onlyOwner
                {
                    tokenBalance[owner]++;
                }
            
            function purchaseToken() public payable
                {
                   require((tokenBalance[owner]*tokenPrice)/msg.value > 0,"not Enough Funds");
                   tokenBalance[owner] = tokenBalance[owner]-(msg.value)/tokenPrice;
                   tokenBalance[msg.sender] = tokenBalance[msg.sender]+(msg.value)/tokenPrice;


                }
            function sendToken(address _to,uint _amount) public
                {
                    tokenBalance[msg.sender] = tokenBalance[owner]- _amount;
                    tokenBalance[_to]+=_amount;
                }
            
        }


