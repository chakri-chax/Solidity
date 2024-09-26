// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ChainlinkPriceOracle{
    AggregatorV3Interface internal priceFeed;

    constructor(){
        priceFeed=AggregatorV3Interface(0x5fb1616F78dA7aFC9FF79e0371741a747D2a7F22);
    }
    function getLatestPriceFeed() public view returns(int){
        (uint80 roundId,
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound)=priceFeed.latestRoundData();
    //for BTC / ETHprice is scaled up by 10^18 sep
    return price/1e18;
    }
}