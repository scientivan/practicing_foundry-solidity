// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MockUSDCUpg} from "../src/MockUSDCUpg.sol";
import {MockUSDCUpgV2} from "../src/MockUSDCUpgV2.sol";
import {TransparentUpgradeableProxy} from
    "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract UpgradeTest is Test {
    MockUSDCUpg public usdcUpgImplementation;
    MockUSDCUpgV2 public usdcUpgV2Implementation;
    address public mockUSDC;

    function setUp() public {
        usdcUpgImplementation = new MockUSDCUpg();
        usdcUpgV2Implementation = new MockUSDCUpgV2();
        mockUSDC = address(new TransparentUpgradeableProxy(address(usdcUpgImplementation), address(this), ""));
    }

    function testUpgrade() public {
        // Check initial version
        address admin = MockUSDCUpg(mockUSDC).getAdmin();
        console.log(admin);
        console.log("version", MockUsdcUpg(mockUSDC).version());

        ProxyAdmin(admin).upgradeAndCall(
            ITransparentUpgradeableProxy(mockUSDC),
            address(usdcUpgV2Implementation),
        );
        console.log("version", MockUSDCUpg(mockUSDC).version());
    }
}
