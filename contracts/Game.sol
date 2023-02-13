// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../contracts/PriceConsumerV3.sol";
import "../contracts/Play.sol";

contract Game{

    address payable GameContractAddress;

    PriceConsumerV3 PriceFeeds;
    Play[] instanceArray;
    
    uint8 players;
    uint256[] indexList;
    int256 public EthFee;
    uint256 refreshTime;

    struct PlayValues{
        address addrVal; 
        uint256 roundVal;
    }

    PlayValues[] public PlayValuesArray;
    
    constructor() {
        GameContractAddress = payable(address(this));
        PriceFeeds = new PriceConsumerV3();
        players = 0;
        setSubscriptionFee();
    }

    event firstPlayer(address p1);
    event bothPlayers(address p1, address p2, uint256 playID);

    modifier onlyContract {
        require(msg.sender == GameContractAddress);
        _;
    }

    receive() external payable {}

    function setSubscriptionFee() public {

        int256 ethPrice = PriceFeeds.getLatestEthPrice();
        int256 amount = ((6*(10**26)) / ethPrice);

        updateEthFee(amount);
    }     

    function updateEthFee(int256 fee) public{
        
        if (block.timestamp >= refreshTime)
        {
            EthFee = fee;
            refreshTime = block.timestamp + 300 seconds;
        }
    }

    
    function proveSubscription() public returns (bool) {
        
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
            uint256 instanceID = arrayLength - 1;
            indexList.push(instanceID);
            
            instanceArray[ instanceID ].setPlayer2(msg.sender) ;
            emit bothPlayers(instanceArray[ instanceID ].player1(), instanceArray[ instanceID ].player2(), instanceID);

            players -= 1;
        } 
    }  

    function getID(address addr) public view returns (uint256) {

        uint256 playerID;

        for (uint256 i=0; i < instanceArray.length; i++){
            if (instanceArray[i].player1() == addr || instanceArray[i].player2() == addr){
                playerID = i;
                break;
            }
        }

        return playerID;
    }

    function checkID(uint256 playID, address addr) public view returns (bool) {

        if ( playID < instanceArray.length )
        {
            Play PlayInstance = instanceArray[playID];
            if (PlayInstance.player1() == addr || PlayInstance.player2() == addr){
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    function playGame(uint256 playID, uint8 guess) public returns (uint64) {
        // check if p1 == p2 
        address player = tx.origin;
        bool result = checkID (playID, player);
        address addr;

        if (result == true) {

            Play PlayInstance = instanceArray[playID];
            uint64 status;

            if ( player == PlayInstance.player1() && PlayInstance.turn() == 1) 
            {
                (address x, uint256 y) = PlayInstance.checkGuess(guess);
                PlayValuesArray.push( PlayValues(x , y) ) ;

                addr = x;
                status = checkWinner(addr, playID);
                
                // code 11 represents: PlayID is true (1) and it was the sender's turn (1)
                if (status == 0){
                    PlayInstance.modifyTurn();
                    return 110;
                } else {
                    return 111;
                }
            } 
            else if ( player == PlayInstance.player2() && PlayInstance.turn() == 2) 
            {
                (address p, uint256 q) = PlayInstance.checkGuess(guess);
                PlayValuesArray.push( PlayValues(p , q) ) ;

                // uint256 b = PlayValuesArray.length;
                // addr = PlayValuesArray[b-1].addrVal;
                status = checkWinner(addr, playID);
                
                // code 12 represents: PlayID is true (1) and it was the sender's turn (2)
                if (status == 0){
                    PlayInstance.modifyTurn();
                    return 120;
                } else { 
                    return 122;
                }
            } else 
            {
                // code 10 means your playID is valid but it's NOT your turn
                return 10;
            }
        } 
        else 
        {
            // code 0 means that the given playID is invalid
            return 0;
        }

    }

    function checkWinner(address addr, uint256 playID) public returns (uint64) {

        Play PlayInstance = instanceArray[playID];
        int256 ethPrice = PriceFeeds.getLatestEthPrice();
        int256 prize = ( (12*(10**26) * 94) / (ethPrice * 100) );

        if (PlayInstance.player1() == addr){
            endGame(addr, prize);
            delete instanceArray[playID];
            return 1;
        } else if (PlayInstance.player2() == addr){
            endGame(addr, prize);
            delete instanceArray[playID];
            return 2;
        } else {
            return 0;
        }
    }

    function endGame(address addr, int256 prize) public { 
        // send  message, delete playerID
        address payable winnerAddr = payable(addr);
        winnerAddr.transfer(uint(prize));
    } 
}