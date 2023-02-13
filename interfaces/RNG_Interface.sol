// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface RNG_Interface{

    function requestNumber(uint32 numberOfWords) external returns(uint256 requestID);

    function getRequestConfigurationValues() external view returns(uint16, uint32, bytes32[] memory);

    function getRandomNumbers() external view returns (uint256[] memory);
   
}
