pragma solidity ^0.5.0;

contract parent
{
    uint internal sum;
     
 function setValues() external
 {   uint a=10;
     uint b=20;
     sum=a+b;
 }

}

contract child is parent
{
    function getValues()external view returns(uint)
    {
        return sum;
    }
}

contract caller
{
    child cc = new child();

    function singleInheritanceResult() public returns(uint)
    {
         cc.setValues();
        return cc.getValues();
    }
}