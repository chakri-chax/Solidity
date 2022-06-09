pragma solidity ^0.8.11;
contract myMappingContract
{
//syntax: mapping(keY=>value) modifier Variable

mapping(uint=>bool) public myMapExam;

//function for true values

function setValueForTrue(uint _index) public 
    {
        myMapExam[_index]=true;
    }

mapping(address=>bool) public MyAddressCheck;

function addressSetTobeTrue() public
    {
        MyAddressCheck[msg.sender]=true;
    }

    //(msg.sender) who (address) is deploying smart contract 

}