// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

//  Contract untuk ngedeploy FundMe
contract DeployFundMe is Script {
    function deployFundMe() public returns (FundMe, HelperConfig) {
        // Untuk tau network mana yang aktif
        HelperConfig helperConfig = new HelperConfig();

        address priceFeed = helperConfig
            .getConfigByChainId(block.chainid)
            .priceFeed;

        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        // mengembalikan address dari contract yang udah dideploy
        return (fundMe, helperConfig);
    }
    // mengembalikan address dari contract yang udah dideploy
    function run() external returns (FundMe, HelperConfig) {
        return deployFundMe();
    }
}
