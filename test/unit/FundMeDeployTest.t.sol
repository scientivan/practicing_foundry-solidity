// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

contract FundMeTest is Test {
    FundMe public fundMe;

    function setUp() public {
        fundMe = new FundMe();
    }
    function testDeploy() public view {
        assertEq(
            address(fundMe.getPriceFeed()),
            address(0),
        );
    }
}
