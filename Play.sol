// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "../contracts/RandomNumberGenerator.sol";
import "../contracts/PriceConsumerV3.sol";

contract Play {
    
    address public player1;
    address public player2;
    
    RandomNumberGenerator RNG_Instance = new RandomNumberGenerator();
    PriceConsumerV3 PriceData = new PriceConsumerV3();

    uint256 public randomNumber;
    uint8 round;
    uint8 oddCount;
    uint8 evenCount;

    function setPlayer1(address addr) public{
        player1 = addr;
    }

    function setPlayer2(address addr) public{
        player2 = addr;
    }

    function playGame() public {
        // check if p1 == p2 
        RNG_Instance.requestNumber();
        randomNumber = RNG_Instance.getRandomNumber();
    }

    function checkGuess(uint8 guess) public {

        address winner;

        if ( ((randomNumber%2) == 1) && (guess == 1) ){
            winner = tx.origin;
            endGame(winner);
        } else if ( (randomNumber%2) == 0  && (guess == 2)) {
            winner = tx.origin;
            endGame(winner);
        } else {
            round++;
        }
        
        if (round < 6)
        {
            playGame();
        }
        else if (round == 6)
        {
            RNG_Instance.requestNumber();
            uint256 a = RNG_Instance.getRandomNumber();

            RNG_Instance.requestNumber();
            uint256 b = RNG_Instance.getRandomNumber();

            RNG_Instance.requestNumber();
            uint256 c = RNG_Instance.getRandomNumber();

            uint8 p = uint8(a%2);
            uint8 q = uint8(b%2);
            uint8 r = uint8(c%2);

            if (p == 0){ evenCount++; } else{ oddCount++; }

            if (q == 0){ evenCount++; } else{ oddCount++; }

            if (r == 0){ evenCount++; } else{ oddCount++; }


            if ( (oddCount == 2) || (oddCount == 3) )
            {
                if(guess == 1)
                {
                    endGame(player1);
                } else
                {
                    endGame(player2);
                }
            }
            
            if ( ( evenCount == 2) || (evenCount == 3) )
            {
                if(guess == 2)
                {
                    endGame(player1);
                } else
                {
                    endGame(player2);
                }
            }
        }
    }

    function endGame(address addr) public { 
        // onlyOwner modifier, send prize and message
        int256 ethPrice = PriceData.getLatestEthPrice();
        int256 prize = ( (12*(10**26) * 94) / (ethPrice * 100) );
        address payable winnerAddr = payable(addr);
        winnerAddr.transfer(uint(prize));
    }
}
