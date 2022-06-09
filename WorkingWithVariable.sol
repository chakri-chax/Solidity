pragma solidity ^0.8.11;
contract workingWithVariables
{
    uint256 public myUint;

    function setmyUnit(uint _myUint_) public
        {
            myUint = _myUint_;
        }

    uint8 public myUint8; //Variable  declaring

    function incrementUint() public
        {
            myUint8++;
        }
    function decrementUnit() public
        {
            myUint8--;
        }
}