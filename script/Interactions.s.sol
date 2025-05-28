// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundingFundMe() is Script {
    uint256 constant SEND_VALUE = 0.1 ether;


    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        // Menjalankan fungsi `fund()` pada kontrak FundMe
        // yang sudah dideploy di blockchain (misalnya Anvil atau Sepolia),
        // di alamat `mostRecentlyDeployed`.
        //
        // Dengan melakukan casting alamat mostRecentlyDeployed ke tipe
        //  `FundMe`, kita bisa memanggil fungsi fund dalam kontrak tersebut.
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded fundMe contract with %s wei", SEND_VALUE);
    } 
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawingFundMe() is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdrew from fundMe contract");
    }
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentlyDeployed);
    }
} 