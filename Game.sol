// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./VRFv2Consumer.sol";

contract Game{

     /**
     * Network: Goerli    Aggregator: ETH/USD, Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
     */
    AggregatorV3Interface internal priceFeed;
    address payable GameContractAddress;
    Play GameInstance;
    uint8 players;
   
    constructor() {
        priceFeed = AggregatorV3Interface( 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e );
        GameContractAddress = payable(address(this));
        players = 0;
    }

    /**
     * Returns the latest price.
     */
    function getLatestPrice() public view returns (int) {
        // prettier-ignore
        ( , int price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    function startGame() public {

        if(players == 0){
            GameInstance = new Play();
            GameInstance.setPlayer1(tx.origin);
            players++;
        } else if (players == 1){
            GameInstance.setPlayer2(tx.origin);
            players++;
        } else if (players == 2) {
            players -= 2;
            startGame();
        }
    }

    // function playGame(address p1, address p2){

    // }

    function randomValue() 
    public 
    returns(uint)
    {
        VRFv2Consumer randContract = new VRFv2Consumer(9139);
        uint256 randomWord  = randContract.requestRandomWords();
        return randomWord;
    }
}


contract Play{
    
    address public player1;
    address public player2;

    function setPlayer1(address addr) public{
        player1 = addr;
    }

    function setPlayer2(address addr) public{
        player2 = addr;
    }

}
