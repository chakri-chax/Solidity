pragma solidity ^0.8.10;

contract mappingStructExample
{
    struct PaymentInStruct
        {
            uint amount;
            uint timeStamp;
        } 
       
    struct BalanceInStruct
        {
            uint totalBalance;
            uint numPayments;
        }

        mapping(address=>BalanceInStruct) public balanceReceived;

        function getBalance() public view returns(uint)
            {
                return address(this).balance;
            }
        function sendMoney() public payable
            {
                balanceReceived[msg.sender].totalBalance = balanceReceived[msg.sender].totalBalance+ msg.value;
            }

        function withdrawMoney(address payable _to,uint _amount) public
            {   
                require(balanceReceived[msg.sender].totalBalance >= _amount,"Not Enough Funds..!!");
                balanceReceived[msg.sender].totalBalance -= _amount; 
                _to.transfer(_amount);
            }
        function withdrawAllMomey(address payable _toAll) public
            {
                uint balanceToSend = balanceReceived[msg.sender].totalBalance;
                balanceReceived[msg.sender].totalBalance = 0;
                _toAll.transfer(balanceToSend);
            }

}
