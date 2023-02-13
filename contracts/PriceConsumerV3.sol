// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {

    AggregatorV3Interface internal ETH_USD_priceFeed;
    AggregatorV3Interface internal BTC_USD_priceFeed;

    /**
     * Network: Goerli      
     * ETH/USD Aggregator, Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
     * BTC/USD Aggregator, Address: 0xA39434A63A52E749F02807ae27335515BA4b07F7
     * Link to ChainLink price feed contract addresses: https://docs.chain.link/data-feeds/price-feeds/addresses/#Goerli%20Testnet
     */
    constructor() {
        ETH_USD_priceFeed = AggregatorV3Interface( 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e );
        BTC_USD_priceFeed = AggregatorV3Interface( 0xA39434A63A52E749F02807ae27335515BA4b07F7 );
    }

    /**
     * Returns the latest price.
     */
    function getLatestEthPrice() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = ETH_USD_priceFeed.latestRoundData();
  
        return price ;
  
    }

    function getLatestBtcPrice() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = BTC_USD_priceFeed.latestRoundData();

        return price ;

    }

}
