# Roulette

## About

This is a two-player zero-sum game. It's based on Russian Roulette. The goal of each player is to guess if a random number is even or odd. The game uses Chainlink's Verifiable Random Function (VRF) as its random number generator (RNG).

Each player sends $6 worth of ETH to the contract address (address payable). Winner takes it all. However, the game-creator retains a 6% charge.

If after 6 rounds there's no winner, the contract generates 3 random numbers and then randomly chooses one of the two players to make the first guess on whether the majority of the 3 numbers is even or odd. Whatever the first player chooses (odd or even) , the opposite is automatically assigned to the other player. The contract then chooses the winner and assigns them the prize.

## Installing

### Pre requisites

1. Environment

- Node JS (Recommended: >= v16.0 )
- Ethers JS (Recommended: >= v5.7 )
- Hardhat. (**OPTIONAL**) This is a development environment that will enable you to compile and deploy your smart contracts

2. Blockchain Account

- An Ethereum account
- Testnet ETH on your Ethereum account. You can get some from here: https://goerlifaucet.com/

### Installation

Simply clone this github repo to get started:

$ git clone https://github.com/Mberic/roulette.git

## How to Play

### Quick Start

The files in this repo already contained a preconfigured contract address on the Georli ETH testnet. You can check the **scripts/interact.js** file for the configurations that you need.

To get started, you only need to configure the following constants in the above file.

- API_KEY = This is the API key given to you by your Web3 provider. 
- PRIVATE_KEY = This is the private key of your Ethereum wallet. If you are using Metamask, you can check out [this documentation](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key) on how to get your  private key. 
- NETWORK = The test network where the contract was deployed. ( This is already configured to “goerli” ) 

After this, you can now run the **interact.js** file to play the game:

$ node interact.js

**NB:** 

This is a two player game. In an ideal situation, you would have to wait for another user/account to subscribe to the game.

For testing purposes, you can play against yourself (the game allows this). Additionally, the game can accurately determine which the player instances (first or second) has won. 

### Deploying on Your Own

You could also decide to compile and deploy the contract on your own. There are a few things you’ll need to note in order to do this:

1. Chainlink’s Verifiable Random Function (VRF) requires you to pay for the random numbers generated using the LINK token. You can get some [testnet LINK from here](https://faucets.chain.link/).
2. There are 2 possible ways in which you can pay for these random numbers: either using a direct pay or through a subscription. The contract implemented here uses the subscription method.  You can read more about how to configure this from [here](https://docs.chain.link/vrf/v2/subscription).

## FAQS

1. Apart from ETH, will there be any other acceptable tokens for subscribing to the game? 
   
   Yes. The project intends to implement the Axelar Interface and allow for cross chain transfers in the future. The following tokens will be supported : BNB, AXL, and more (yet to be decided).


2. Does the project intend to accept higher denominations in the future?
   
   Yes. Later on, the project will have a provision for a higher subscriptions of $60 and $600.


3. Why are there 6 rounds and why is this number used a lot?
   
   This game is based on Russion roulette. In this game, the gun primarily used is a revolver (which has a compartment for 6 bullets). 
