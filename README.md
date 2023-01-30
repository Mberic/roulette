# Roulette
This is a two-player zero-sum game. It's based on Russian Roulette. 

The  goal of each player is to guess if a random number is even or odd. The game uses Chainlink's Verifiable Random Function (VRF) as its random number generator (RNG).

Each player sends $6 worth of ETH to the contract address (address payable). Winner takes it all. However, the game-creator retains a 6% charge. 

If after 6 rounds there's no winner, the contract generates 3 random numbers and then randomly chooses one of the two players to make the first guess on whether the majority of the 3 numbers is even or odd. Whatever the first player chooses (odd or even) , the opposite is automatically assigned to the other player. The contract then chooses the winner and assigns them the prize.
