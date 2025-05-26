// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    //     Counter public counter;
    // harusnya tambahin constructor?
    function setUp() public {}
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceConfig = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceConfig);
        vm.stopBroadcast();
        return fundMe;
    }
}
