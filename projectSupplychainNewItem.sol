pragma solidity ^0.8.7;
 import "./projectSupplyChain.sol";

contract newItem
    {
        uint public index;
        uint public priceInWei;
        uint public paidWei;
        
        ItemManager parentContract;

        constructor(uint _index, uint _priceInWei, ItemManager _parentContract ) public    
            {
                index = _index;
                priceInWei = _priceInWei;
                parentContract = _parentContract;

            }

        receive() external payable
            {
                require(msg.value == priceInWei,"we dont support partial transactions");
                require(paidWei==0,"item is already paid");

                paidWei+=msg.value;
                //(bool success, ) = address(parentContract).call{value:msg.value}(abi.encodeWithSignature("triggerPayment(uint256)", index));
                (bool success,) = address(parentContract).call
                                    {value:msg.value}
                                    (abi.encodeWithSignature("payment(uint256)",index));
                require(success,"delivery didnt work...");
            }

            fallback() external
                {
                    
                }
    }