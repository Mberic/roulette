// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract RandomNumberGenerator is VRFConsumerBaseV2 {
    
    uint64 s_subscriptionId;
    address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D; 
    bytes32 s_keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint32 callbackGasLimit = 600000;
    uint16 requestConfirmations = 5;
    uint32 numWords =  1;

    uint256 public randomNum;
    uint256 public requestIdentification;

    VRFCoordinatorV2Interface COORDINATOR;
    
    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
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

    function assignRequestId() public {
        requestIdentification = requestNumber();
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

}

 /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes

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
    
