//do While
pragma solidity ^0.5.0;

contract doWhile
{
    uint i=0;
    uint[] data;

    function doWhileResult()public returns(uint[] memory)
    {
      do
      {     
          if(i==4)
          {
              continue;
          }
          data.push(i);
          i++;
      }
       while(i<=5);
      return data;
    }
}