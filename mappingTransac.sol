pragma solidity ^0.8.11;

contract mappingTransaction
{
    mapping(address=>uint) public balanceReceived;


    // mana address lo entha undhi "balanceReceived" ee variable lo untundhi

    
    function getBalance() public view returns(uint) //deposit chesina tarvatha entha undho ani telustundhi...
        {
            return address(this).balance;
        }
            
    function depositMoney() public payable //mana entha deposit chesukuntunnam
        {
            balanceReceived[msg.sender]+=msg.value;
        }

           
    function withdrawMoneyAaddress(address payable _to, uint _amt) public  //manam evariki entha pampistunnam...
        {       //if condition type idhi... #balance saripothundho ledho ani checking

            require(balanceReceived[msg.sender] >= _amt,"Not Enough Funds");
            
           
            //transfer iyyina tarvatha balance taggali kadha mari
             balanceReceived[msg.sender] -= _amt;

             //simple transaction Syntax
            _to.transfer(_amt);
        }

    function withdrawAllMoney(address payable _to) public
        {   //okka withdraw option unte chalu... idhi optional
             _to.transfer(getBalance());
        }
}