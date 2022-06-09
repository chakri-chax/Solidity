pragma solidity ^0.8.11;

contract TransBetTwoAddresses
{   
    address public fromAddress;
    address public toAddress;

    function setfromAdrress(address _fromAdrs) public
        {
            fromAddress = _fromAdrs;
        }
    function setToAddress(address _toAdrs) public
        {
            toAddress = _toAdrs;
        }

    function getFromAddressBalance() public view returns(uint)
        {
            return fromAddress.balance;
        }
   
    function getToAddressBalance() public view returns(uint)
        {
            return toAddress.balance;
        }
    
    //trasaction Begin
    uint public balRecieve;

    function balReceived() public payable
    {
        balRecieve += msg.value;
    }

    function checkBalance() public view returns(uint)
    {
        return fromAddress.balance;
    }
   
}