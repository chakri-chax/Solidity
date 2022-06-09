pragma solidity ^0.8.11;

contract pauseTransac
{  address public owner;
    bool paused;
    constructor()
        {
           owner = msg.sender;
        }

    function sendMoney() public payable
    {       }

    function withdrawAllEthers(address payable _to) public
    {   require(owner==msg.sender,"You not owner....");
         require(paused == false, "Contract Paused");
         
       _to.transfer(address(this).balance);
    }
}