pragma solidity ^0.8.11;
contract BalancedReceive
{
    uint public balReceive;
    
    function getMoney() public payable
        {
             balReceive += msg.value;
        }
    function showMoney() public view returns(uint)
        {
            return address(this).balance;
        }
    
    function sendMoney(address payable _towhich) public
        {
            _towhich.transfer(this.showMoney());
        }
}
