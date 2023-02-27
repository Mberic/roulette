const { ethers } = require("ethers");
const abi = require("../learning-js/Game.json");
const readline = require('readline').createInterface(
 {
    input: process.stdin,
    output: process.stdout,
  }
);

const CONTRACT_ADDRESS1 = ""; // goerli contract
const CONTRACT_ADDRESS2 = ""; // bsc testnet contract

const API_KEY = "";
const PRIVATE_KEY = "";

const network = "goerli";
const bsc_jsonRPC_testnet = "https://data-seed-prebsc-1-s1.binance.org:8545/" 

const provider1 = new ethers.providers.AlchemyProvider(network, API_KEY );
const provider2 = new ethers.providers.JsonRpcProvider(bsc_jsonRPC_testnet) 

const signer1 = new ethers.Wallet(PRIVATE_KEY, provider1);
const signer2 = new ethers.Wallet(PRIVATE_KEY, provider2);

const contract1 = new ethers.Contract( CONTRACT_ADDRESS1 , abi1 , signer1 );
const contract2 = new ethers.Contract( CONTRACT_ADDRESS2 , abi2 , signer2 );

const publicAddress = ;

function chooseChain(){
    readline.question(

        'WELCOME\n Please choose a network you will be playing from' +
        '\nPress 1 for Ethereum Network (Goerli)'+
        '\nPress 2 for BSC (Testnet)\n\n', 
        
        choice => {
        
        if (choice == 1){
            console.log(`You have chosen the Ethereum network`);
            readline.close();
            subscribe("goerli");

        } else if (choice == 2){
            console.log(`You have chosen the Binance network`);
            readline.close();
            subscribe("bsct")
        } 
        });
}

async function subscribe(chain) {

    if (chain = "goerli") {

    let value = contract1.gameFee() ** -8;
    let fee = ethers.utils.parseEther(value.toString());

    contract1.subscribeToGame({value: fee});

    registrationStatus();
    start();
    } else {
    
    let amount = 0.02;
    let fee = ethers.utils.parseEther(amount.toString());

    let gasAmount = 0.16;
    let gasfee = ethers.utils.parseEther(gasAmount.toString());

    let tokenABI = ["function approve(address _spender, uint256 _value) public returns (bool success)"];
    let tokenAddress = "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd";
    let spendAmount = fee;

    let TokenContract = new ethers.Contract(tokenAddress, tokenABI, signer);   
    await TokenContract.approve(CONTRACT_ADDRESS, spendAmount);

    await contract2.paySubscription(fee ,{ value: gasfee } );

    registrationStatus();
    start();
    }

}

async function registrationStatus(){
    contract1.on("playerRegistered", (player) => {

        if (player == 1){
            console.log("You are player 1");
        } else {
            console.log("You are player 2");
            play();
        } 
    });
}

async function start(){
    
    let playID = await contract1.getID(publicAddress);

    if (playerID == 0){
    
        readline.question("ROULETTE GAME\n" + "You don't have a GameID\n", + "If you would like to play, PLEASE press 8",

            function (userInput) {
            
            if (userInput == 8){
                chooseChain();
            } else {

            }
            readline.close();
         });

    } else{
        console.log("\n\nYou already have an ongoing game \nPlease make a guess");
        console.log("\nTo guess if the random number is ODD, press 1 \nTo guess if the random number is EVEN, press 2");
        
        readline.question("PLEASE make a guess :",

            function (userGuess) {
            
            if (userGuess == 1){
                play(playID, userGuess);
            } else if (userGuess == 2) {
                play(playID, userGuess);
            }
            readline.close();
         });

    }
}

async function play(playID, guess){

    let code = await contract.playGame(playID, guess);

    if (code == 110){
        console.log("Your guess didn't turn out right...\n Please wait for your opponent to play");
    } else if (code == 111) {
        console.log("You won! Hurray! \n\n Please wait for a confirmation of the delivery of your prize");
    }

    if (code == 120){
        console.log("Your guess didn't turn out right...\n Please wait for your opponent to play");
    } else if (code == 122) {
        console.log("You won! Hurray! \n\n Please wait for a confirmation of the delivery of your prize");
    }

    if (code == 10){
        console.log("Please wait your turn...")
    } else if (code == 0) {
        console.log("Your PlayID is invalid")
    }
}


/** 
 * provider.getBalance( address [ , blockTag = latest ] ) provider.getTransactionCount( address [ , blockTag = latest ] )
 * provider.getNetwork( ) 
 * provider.getBlockNumber( ) 
 * provider.getGasPrice( ) ⇒ Promise< BigNumber >
 * provider.estimateGas( transaction )  
 * 
 * 
 * 
 * */
