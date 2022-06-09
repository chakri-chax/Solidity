//35 program
pragma solidity 0.8.11;
contract transaction 
{
    uint public balReceived;
    function receiveMoney() public payable
    {
        balReceived += msg.value;
    }
    function checkBalance() public view returns(uint)
    {
        return address(this).balance;
    }
    function withdraw() public
    {
        address payable toWhich = payable(msg.sender);
        toWhich.transfer(checkBalance());
    }
    function adrsWithdrawToWhich(address payable _toWhich) public
    {
        _toWhich.transfer(checkBalance());
    }
} 