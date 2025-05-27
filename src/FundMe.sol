// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5e18;
    // addressnya para funder
    address[] private s_funders;
    // address yang deploy contract fundMe ini
    address private immutable i_owner;
    // mengakses harga dari ETH ke USD menggunakan
    // interface library AggregatorV3Interface
    // s_priceFeed berbentuk aggregatorv3interface
    AggregatorV3Interface private s_priceFeed;

    mapping(address funderAddress => uint256 amountFunded)
        private s_addressToAmountFunded;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH"
        );
        // default awalnya adalah 0, ini untuk ngehandle kasus apabila awalnya sender udah ada balance trus dia ngefund lagi
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    // ngewithdraw semua dana yang telah diberikan oleh sender ke owner dan diberikan modifier onlyOwner agar keamanannya terjaga
    function withdraw() public onlyOwner {
        address[] memory funders = s_funders;
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0; //di reset jadi 0
        }
        // reset array funders dengan panjangnya menjadi 0
        s_funders = new address[](0);
        // .call ngereturn boolean yang untuk send errornya harus menggunakan revert melalui keyword require
        (bool callSuccess, ) = i_owner.call{value: address(this).balance}("");
        require(callSuccess);
    }

    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }

    /**
        View / Pure functions (Getters)
    */

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getAddressToAmountFunded(
        address funderAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[funderAddress];
    }

    function getFunderAddress(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwnerAddress() external view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        // artinya apabila conditioning diatas tidak berlaku, jalankan code selanjutnya pada function yang menggunakan modifier ini
        _;
    }
}
