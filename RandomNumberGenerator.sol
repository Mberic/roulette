// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract RandomNumberGenerator is VRFConsumerBaseV2 {
    
    uint64 s_subscriptionId = 9139;
    address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D; 
    bytes32 s_keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint32 callbackGasLimit = 600000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  1;

    uint256 randomNum;
  
    VRFCoordinatorV2Interface COORDINATOR;
    
    constructor () VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    }
    
    event numberRequested(uint256 indexed requestId);
    event valueFound(uint256 indexed requestId, uint256 indexed result);


    function requestNumber() public returns(uint256 requestId){
        
        requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        emit numberRequested(requestId);
    }


    function getRequestConfigurationValues() public view returns(uint16, uint32, bytes32[] memory){

        return COORDINATOR.getRequestConfig();
    }


    function fulfillRandomWords
    (uint256 requestId, uint256[] memory randomWords) 
    internal override{
        
        randomNum = randomWords[0];
        emit valueFound(requestId, randomNum);
    }


    function getRandomNumber()
    public
    view
    returns (uint256){
        return randomNum;
    }

}

 /**
    function getRequestConfig()
        external
        view
        returns (
        uint16,
        uint32,
        bytes32[] memory
        );

    */

    /**
        function requestRandomWords(
            bytes32 keyHash,
            uint64 subId,
            uint16 minimumRequestConfirmations,
            uint32 callbackGasLimit,
            uint32 numWords
        ) external returns (uint256 requestId);
    */
    