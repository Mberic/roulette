// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../contracts/RandomNumberGenerator.sol";
import "../contracts/PriceConsumerV3.sol";
import "../contracts/Play.sol";

contract Game{

    address payable GameContractAddress;
    PriceConsumerV3 PriceFeeds;
    Play[] instanceArray;
    
    uint8 players;
    int256 public EthFee;
    uint256 refreshTime;
    
    string internal info_failure = "Insufficient fee";
    string internal info_success = "Welcome to the game";

    constructor() {
        GameContractAddress = payable(address(this));
        PriceFeeds = new PriceConsumerV3();
        players = 0;
        setSubscriptionFee();
    }

    event firstPlayer(address p1);
    event bothPlayers(address p1, address p2);

    
    function setSubscriptionFee() public {

        int256 ethPrice = PriceFeeds.getLatestEthPrice();
        int256 amount = ((6*(10**26)) / ethPrice);

        updateEthFee(amount);
    }

    function setEthFee(int256 fee) public{
        EthFee = fee;
    }

    function updateEthFee(int256 fee) public{
        
        if (block.timestamp >= refreshTime)
        {
            setEthFee(fee);
            refreshTime = block.timestamp + 300 seconds;
        }
    }

    function checkFee(int256 fee) internal view returns (bool) {

        if (fee == EthFee){
            return true;
        } else {
            return false;
        }
    }


    function subscribeToGame(int256 fee) public returns (string memory ) {
        
        if (checkFee(fee) == true) 
        { 
            startGame();
            return info_success;
        } 
        else 
        { 
            return info_failure; 
        }
    }

    function startGame() public {

        if(players == uint8(0))
        {
            Play PlayInstance = new Play();
            PlayInstance.setPlayer1(msg.sender);

            players++;
            instanceArray.push(PlayInstance);
            emit firstPlayer(PlayInstance.player1());
        } 
        else if (players == uint8(1))
        {
            uint256 arrayLength = instanceArray.length;
            instanceArray[ arrayLength -1 ].setPlayer2(msg.sender) ;
            emit bothPlayers(instanceArray[ arrayLength -1 ].player1(), instanceArray[ arrayLength -1 ].player2());

            players -= 1;
        } 
    }  
}

