//While loop

pragma solidity ^0.5.0;

contract WhileLoop
{
    uint i=0;
    uint[] data; //declaring array

    function LoopResult() public returns(uint[] memory)

    {
        while(i<=5)
        {
            if(i==3)
            {
                break;
            }
            
            data.push(i);//push keyword for APPENDING VALUES    
            i++;

            
        }
        return data; 
    }

}