const { ethers } = require("ethers");
const abi = require("../artifacts/contracts/Game.sol/Game.json");
const readline = require('readline').createInterface
(
 {
    input: process.stdin,
    output: process.stdout,
  }
);

const CONTRACT_ADDRESS = "0x073AAfC1357108eBDcAE11780cE4b18155b0364D";
const API_KEY = "bLOQXMCKxwCUQakDFFQmjZzGfUIvjxpy";
const PRIVATE_KEY = "";

const network = "goerli";
const bsc_jsonRPC_testnet = "https://data-seed-prebsc-1-s1.binance.org:8545/" // json RPC url

const provider = new ethers.providers.JsonRpcProvider(bsc_jsonRPC_testnet) // provider for signing transaction
// const provider = new ethers.providers.AlchemyProvider(network, API_KEY );

const signer = new ethers.Wallet(PRIVATE_KEY, provider);
const contract = new ethers.Contract( CONTRACT_ADDRESS , abi , signer );
const publicAddress = ;

async function subscribe() {
    
    if (chainResponse = "goerli") {

    let value = contract.gameFee() ** -18;
    let fee = ethers.utils.parseEther(value.toString());

    contract.subscribeToGame({value: fee});

    registrationStatus();
    start();
    } else {
    
    let amount = 0.02;
    let fee = ethers.utils.parseEther(amount.toString());

    let gasAmount = 0.18;
    let gasfee = ethers.utils.parseEther(gasAmount.toString());

    let tokenABI = ["function approve(address _spender, uint256 _value) public returns (bool success)"];
    let tokenAddress = "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd";
    let spendAmount = fee;

    let TokenContract = new ethers.Contract(tokenAddress, tokenABI, signer);   
    await TokenContract.approve(CONTRACT_ADDRESS, spendAmount);

    await contract.paySubscription(fee ,{ value: gasfee } );

    registrationStatus();
    start();
    }

}

async function registrationStatus(){
    contract.on("playerRegistered", (player) => {

        if (player == 1){
            console.log("You are player 1");
        } else {
            console.log("You are player 2");
            play();
        } 
    });
}

async function start(){

    let playID = contract.getID(publicAddress);
    let response;

    if (playerID == 0){
    
        let response = "";

        readline.question("WELCOME\n Would like to subscribe to a new game?\n", function (userInput) {
            response = userInput;
            readline.close();
        });
         
        if(response == "yes"){
           subscribe();
        } else if (response == "no") {
        }

    } else{
        console.log("You already have an ongoing game");
        play(playID, guess);
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

subscribe();

/** 
 * provider.getBalance( address [ , blockTag = latest ] ) provider.getTransactionCount( address [ , blockTag = latest ] )
 * provider.getNetwork( ) 
 * provider.getBlockNumber( ) 
 * provider.getGasPrice( ) ⇒ Promise< BigNumber >
 * provider.estimateGas( transaction )  
 * 
 * */
