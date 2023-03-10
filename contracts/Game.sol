// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../interfaces/IAxelarExecutable.sol";
import "../contracts/PriceConsumerV3.sol";
import "../contracts/Play.sol";

contract Game is IAxelarExecutable {

    address payable GameContractAddress;
    address gatewayAddr = 0xe432150cce91c13a887f7D836923d5597adD8E31;
    
    PriceConsumerV3 PriceFeeds;
    Play[] instanceArray;
    
    uint8 players;
    uint256[] indexList;
    int256 public gameFee;
    uint256 private refreshTime;

    struct PlayValues{
        address addrVal; 
        uint256 roundVal;
    }

    PlayValues[] public PlayValuesArray;
    
    constructor() IAxelarExecutable(gatewayAddr) {

        gateway = IAxelarGateway(gatewayAddr);
        GameContractAddress = payable(address(this));
        PriceFeeds = new PriceConsumerV3();
        players = 0;
    }

    event firstPlayer(address p1);
    event bothPlayers(address p1, address p2, uint256 playID);
    event playerRegistered (uint8 player);

    event crosschainSubscriber(string sourceChain, string sourceAddress, address payload, string tokenSymbol, uint256 amount);

    modifier onlyContract {
        require(msg.sender == GameContractAddress);
        _;
    }

    receive() external payable {}

    function updateFee() private onlyContract {

        int256 ethPrice = PriceFeeds.getLatestEthPrice();
        int256 amount = ((6*(10**26)) / ethPrice);

        if (block.timestamp >= refreshTime)
        {
            gameFee = amount;
            refreshTime = block.timestamp + 200 seconds;
        }
    }   

    function getUpdatedFee() public returns (int256) {
        updateFee();
        return gameFee;
    }
    
    function subscribeToGame() external payable returns (bool success) {

        require( msg.value == uint(getUpdatedFee()), "Insufficient fee" ); 
        setPlayers(msg.sender);
        return true;       
    }

    function _executeWithToken(
        string memory sourceChain,
        string memory sourceAddress,
        bytes calldata payload,
        string memory tokenSymbol,
        uint256 amount
    ) internal override {

        address subscriber = abi.decode(payload, (address));
        setPlayers(subscriber);

        emit crosschainSubscriber(sourceChain, sourceAddress, subscriber, tokenSymbol, amount);
    }


    function setPlayers(address player) private onlyContract {

        if(players == uint8(0))
        {
            Play PlayInstance = new Play();
            PlayInstance.setPlayer1(player);

            players++;
            instanceArray.push(PlayInstance);
            emit firstPlayer(PlayInstance.player1());
            emit playerRegistered(1);
        } 
        else if (players == uint8(1))
        {
            uint256 arrayLength = instanceArray.length;
            uint256 instanceID = arrayLength - 1;
            indexList.push(instanceID);
            
            instanceArray[ instanceID ].setPlayer2(player) ;
            emit bothPlayers(instanceArray[ instanceID ].player1(), instanceArray[ instanceID ].player2(), instanceID);
            emit playerRegistered(2);
            players -= 1;
        } 
    }  

    function getID(address addr) public view returns (uint256) {

        uint256 playID;

        for (uint256 i=0; i < instanceArray.length; i++){
            if (instanceArray[i].player1() == addr || instanceArray[i].player2() == addr){
                playID = i+1;
                break;
            }
        }

        return playID;
    }

    function checkID(uint256 playID, address addr) public view returns (bool) {

        if ( playID > 0 && playID <= instanceArray.length )
        {
            Play PlayInstance = instanceArray[playID-1];
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

            Play PlayInstance = instanceArray[playID-1];
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

        Play PlayInstance = instanceArray[playID-1];
        int256 ethPrice = PriceFeeds.getLatestEthPrice();
        int256 prize = ( (12*(10**26) * 94) / (ethPrice * 100) );

        if (PlayInstance.player1() == addr){
            endGame(addr, prize);
            delete instanceArray[playID-1];
            return 1;
        } else if (PlayInstance.player2() == addr){
            endGame(addr, prize);
            delete instanceArray[playID-1];
            return 2;
        } else {
            return 0;
        }
    }

    function endGame(address addr, int256 prize) private onlyContract { 
        // send  message, delete playerID
        address payable winnerAddr = payable(addr);
        winnerAddr.transfer(uint(prize));
    } 
}

