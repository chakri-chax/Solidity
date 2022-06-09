pragma solidity ^0.8.11;

contract addrsBal
{
    address public myAddress;

    function setMyAdrs(address _myAddrs) public
        {
            myAddress = _myAddrs;
        }

    function getMyBal() public view returns(uint)
    {
        return myAddress.balance;
    }

}