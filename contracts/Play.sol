// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "../contracts/RandomNumberGenerator.sol";
import "../contracts/PriceConsumerV3.sol";
import "../interfaces/RNG_Interface.sol";

contract Play {
    
    address public player1;
    address public player2;
   
    address RNG_contract_address = 0x7eE6Be5Cf15b74c205246964DfDA8DE32F8110cB;
    PriceConsumerV3 PriceData = new PriceConsumerV3();
    RNG_Interface RNG_Instance = RNG_Interface(RNG_contract_address);
          
    uint256[] public randomValues;
    uint256[] public finalRandomValues;
    
    uint8 public round;
    uint8 public turn = 1;
    uint8 oddCount;
    uint8 evenCount;

    function setPlayer1(address addr) public{
        player1 = addr;
    }

    function setPlayer2(address addr) public{
        player2 = addr;
    }

    function modifyTurn() public {

        if (turn == 1)
        {
            turn += 1;
        } else {
            turn -= 1;
            round++;
        }
    }

    function setRandomValues(uint32 num) public {

        uint256 requestId;
        
        requestId = RNG_Instance.requestNumber(num);
        randomValues = RNG_Instance.getRandomNumbers();

        uint256 timeWait = block.timestamp  + 200;

        while (randomValues.length == 0)
        {
            refresh();
            if (block.timestamp > timeWait){
                break;
            }
        }
    }

    function refresh() public view { }

    function checkGuess(uint8 guess) public returns (address addr, uint256 roundValue) {

        if  (round == 0){
            setRandomValues(6);
        }

        if ( round < 6 ){

            roundValue = randomValues[round];

            if ( ((roundValue %2) == 1) && (guess == 1) ){ // player guesses odd number
                addr = tx.origin;
                return (addr,roundValue) ;
            } else if ( (roundValue %2) == 0  && (guess == 2)) { // player guesses even number
                addr = tx.origin;
                return (addr,roundValue);
            } else{
                return (addr,roundValue);
            }

        } 
        else if (round == 6 ){
            armageddon(guess);
        }
        
    }

    function armageddon(uint32 guess) public returns (address addr, uint256 roundValue) {

        uint256 requestId;
        uint256 timeWait = block.timestamp + 200;
        
        RNG_Interface RNG = RNG_Interface(RNG_contract_address);
        requestId = RNG.requestNumber(3);
        finalRandomValues = RNG.getRandomNumbers();
       
        while (finalRandomValues.length == 0)
        {
            refresh();
            if (block.timestamp > timeWait){
                finalRandomValues = RNG.getRandomNumbers();
                break;
            }
           
        }

        uint256 p = finalRandomValues[0] %2 ;
        uint256 q = finalRandomValues[1] %2 ;
        uint256 r = finalRandomValues[2] %2 ;

        /** The sum below will enable client app determine
            *  if majority of random values 
            *  was odd or even
        **/
        roundValue = p + q + r; 

        if (p == 0) { evenCount++; } else { oddCount++; }
        if (q == 0) { evenCount++; } else { oddCount++; }
        if (r == 0) { evenCount++; } else { oddCount++; }

        if ( (oddCount == 2) || (oddCount == 3) )
        {  
            if(guess == 1) { 
                addr = player1;
                return (addr, roundValue); 
            } else 
            { 
                addr = player2;
                return (addr, roundValue); 
            }
        }

        if ( ( evenCount == 2) || (evenCount == 3) )
        {
            if(guess == 2) 
            { 
                addr = player1;
                return (addr, roundValue); 
            } else { 
                addr = player2;
                return (addr, roundValue); 
            }
        }
    }
}

