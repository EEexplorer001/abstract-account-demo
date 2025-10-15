// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";

contract SendPackedUserOp is Script {
    using MessageHashUtils for bytes32;

    function run() public {
        // HelperConfig helperConfig = new HelperConfig();
        // // native usdc for arbitrum
        // address dest = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
        // uint256 value = 0;
        // bytes memory functionData = abi.encodeWithSelector(IERC20.approve.selector, );
        // bytes memory executeCallData = abi.encodeWithSelector(MinimalAccount.execute.selector, dest, value, functionData);
        // PackedUserOperation memory userOp = generateSignedUserOperation(
        //     executeCallData,
        //     helperConfig.getConfig(),
        //     address(minimalAccount)
        // );
        // PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        // ops[0] = userOp;

        // vm.startBroadcast();
        // IEntryPoint(helperConfig.getConfig().entryPoint).handleOps(ops, helperConfig.getConfig().account);
    }
    

    function generateSignedUserOperation(
        bytes memory callData, 
        HelperConfig.NetworkConfig memory config,
        address minimalAccount
    ) 
        public 
        view
        returns (PackedUserOperation memory) 
    {
        // 1. Generate the unsigned data
        uint256 nonce = vm.getNonce(minimalAccount) - 1; // why -1?
        // The sender should be the minimal account
        PackedUserOperation memory unsignedUserOp = _generateUnsignedUserOperation(callData, minimalAccount, nonce);

        // 2. Get the userOp hash
        bytes32 userOpHash = IEntryPoint(config.entryPoint).getUserOpHash(unsignedUserOp);
        bytes32 digest = userOpHash.toEthSignedMessageHash();

        // 3. Sign the hash
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        if (block.chainid == 31337) {
            (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, digest);
        } else {
            (v, r, s) = vm.sign(config.account, digest);
        }
        unsignedUserOp.signature = abi.encodePacked(r, s, v); // Note the order
        return unsignedUserOp; // It is now signed
    }

    function _generateUnsignedUserOperation(
        bytes memory callData, 
        address sender,
        uint256 nonce
    ) 
        internal 
        pure 
        returns (PackedUserOperation memory) 
    {
        uint128 verificationGasLimit = 16777216;
        uint128 callGasLimit = verificationGasLimit;
        uint128 maxPriorityFeePerGas = 256;
        uint128 maxFeePerGas = maxPriorityFeePerGas;

        return PackedUserOperation({
            sender: sender,
            nonce: nonce,
            initCode: hex"",
            callData: callData,
            accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
            preVerificationGas: verificationGasLimit,
            gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas), // EIP-1559 gas model
            paymasterAndData: hex"",
            signature: hex""
        });
    }
}