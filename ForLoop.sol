//ForLoop

pragma solidity ^0.5.0;

contract ForLoop
{
    uint[] data;
    
    function ForLoopResult() public returns(uint[] memory)
    {
        for(uint i=0;i<=5;i++)
        {
            data.push(i);
        }
        return data;
    }
}