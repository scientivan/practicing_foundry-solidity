// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {HelperConfig, CodeConstants} from "../script/HelperConfig.s.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test, CodeConstants {
    FundMe public fundMe;
    HelperConfig public helperConfig;

    // Constants var in testing mode
    uint160 public constant USER_NUMBER = 50;
    address public constant USER = address(USER_NUMBER);
    uint256 constant MINIMUM_USD = 5e18;
    uint256 public constant SEND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;

    function setUp() external {
        // testing in local blockchain with anvil
        // nge deploy contract deployFundMe yang mendeploy fundMe untuk dilakukkan testing
        DeployFundMe deployer = new DeployFundMe();
        (fundMe, helperConfig) = deployer.deployFundMe();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), MINIMUM_USD);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwnerAddress(), msg.sender);
    }

    function testPriceFeedSetCorrectly() public {
        address retrievedPriceFeed = address(fundMe.getPriceFeed());
        console.log(retrievedPriceFeed);
        address expectedPriceFeed = helperConfig
            .getConfigByChainId(block.chainid)
            .priceFeed;
        console.log(expectedPriceFeed);
        assertEq(retrievedPriceFeed, expectedPriceFeed);
    }

    function testFundFailsWithoutEnoughETH() public {
        // code atau logic apapun yang ada dibawah ini akan true apabila semuanya false
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesAfterFunded() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(address(50));
        fundMe.withdraw();
    }

    function testWithdrawFromASingleSender() public funded {
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwnerAddress().balance;

        vm.startPrank(fundMe.getOwnerAddress());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwnerAddress().balance;
        uint256 expectedOwnerBalance = startingOwnerBalance +
            startingFundMeBalance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, expectedOwnerBalance);
    }

    function testWithdrawFromMultipleSender() public funded {
        uint256 numberOfFunders = 10;
        uint160 startingUserIndex = 2 + USER_NUMBER;

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwnerAddress().balance;

        for (uint160 i = startingUserIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 afterFundedFundMeBalance = address(fundMe).balance;
        assert(address(fundMe).balance > 0);

        vm.startPrank(fundMe.getOwnerAddress());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        uint256 endingOwnerBalance = startingOwnerBalance +
            afterFundedFundMeBalance;
        assert(endingOwnerBalance == fundMe.getOwnerAddress().balance);
    }

    function testAddsSenderToArrayOfFunder() public funded {
        address funder = fundMe.getFunderAddress(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testGetVersion() public {
        uint256 version = fundMe.getVersion();
        console.log(version);
    }
}
