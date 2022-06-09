pragma solidity ^0.8.11;
//callback function
//destroy function
//view and pure
//constructor


contract ExampleFunction 
{   address payable public owner;
    function sendMoney() public payable
    {

    }
    function balanceReceived() public view returns(uint)
    {
        return address(this).balance;
    }
    constructor() public
        {   
            owner =payable(msg.sender);
        }
    function destroy() public
    {
        require(msg.sender == owner,"You are not allowed");
        selfdestruct(owner);  
    }

    function weiToEther( uint _amount) public pure returns(uint)
        {
            return _amount /1 ether;
        }

    receive() external payable //fallBack 
    {
        balanceReceived();
    }
}
