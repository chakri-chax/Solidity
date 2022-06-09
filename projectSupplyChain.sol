pragma solidity ^0.8.7;

import "./projectSupplyChainNewItem.sol";

contract ItemManager 


    {
        enum supplyChainSteps
            {
                created,paid,deleverd
            }
        
        struct s_items
            {
                ItemManager.supplyChainSteps steps;//at what position item was
                string identifier; //ItemName
                uint priceInWei;//ItemPrice
            } mapping(uint =>s_items) public items;

                uint index;

            event whereItIs(uint _itemIndex,uint step);

            function created(string memory _identifier,uint _priceInWei) public
                {
                    // ==>
                    newItem item =  new newItem(this,index,_priceInWei);

                    

                    //<==

                    items[index].identifier = _identifier;
                    items[index].priceInWei = _priceInWei;
                    items[index].steps = supplyChainSteps.created; //in func paranthesis 
                                                                //we didn't declare so                   
                                                                //in line 23 we assign like that
                    
                    
                    emit whereItIs(index,uint(items[index].steps));
                    index++;
                }

            function payment(uint _index) public payable
                {
                    // it must be created 
                    // amount must be equal 

                    
                    require(items[_index].steps == supplyChainSteps.created,"Item was not created yet");
                    require(items[_index].priceInWei<=msg.value,"correction in price");
                    items[_index].steps = supplyChainSteps.paid;

                     emit whereItIs(_index,uint(items[index].steps));
                }
            function devliverd(uint _index) public
                {
                    //it must be paid
                    require(items[_index].steps == supplyChainSteps.paid,"not paid foe this item");
                    items[_index].steps = supplyChainSteps.deleverd;

                     emit whereItIs(_index,uint(items[index].steps));
                }
    }