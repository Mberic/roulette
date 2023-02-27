// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';

contract BinanceSourceChain {

    address gatewayContract = 0x4D147dCb984e6affEEC47e44293DA442580A3Ec0;  
    address gasContract = 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6; 
    
    IAxelarGateway GatewayInstance = IAxelarGateway(gatewayContract);
    IAxelarGasService gasReceiver = IAxelarGasService(gasContract);

    string destinationChain = "ethereum-2";
    string destinationContractAddress = "0x7f40559E3ED0766A35403df6E87aaAdCB79E2BAD";
       
    function paySubscription (uint256 amount) external payable{
  
        string memory symbol = "WBNB";
     
        address tokenAddress = GatewayInstance.tokenAddresses(symbol);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        IERC20(tokenAddress).approve(address(GatewayInstance), amount);
        bytes memory payload = abi.encode(msg.sender);

        if(msg.value > 0) {
            // The line below is where we pay the gas fee
            gasReceiver.payNativeGasForContractCallWithToken{value: msg.value}(
                address(this),
                destinationChain,
                destinationContractAddress,
                payload,
                symbol,
                amount,
                tx.origin
            );
        }

        GatewayInstance.callContractWithToken(destinationChain, destinationContractAddress, payload, symbol, amount);
    }

    receive() external payable{} 
}

/**
    // This is called on the source chain before calling the gateway to execute a remote contract.
    
    function payNativeGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable;

**/

