pragma solidity ^0.8.11;
contract strings
{
    string myString;

    function setString(string memory _myString) public
    {
        myString = _myString;
    }
    function getStringfrom() public view returns(string memory)
    {
        return myString;
    }
}