// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe{
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5e18;
    mapping(address funderAddress => uint256 amountFunded) public addressToAmountFunded;
    address[] public funders;
    address public immutable i_owner;

    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH");
        // default awalnya adalah 0, ini untuk ngehandle kasus apabila awalnya sender udah ada balance trus dia ngefund lagi
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);    
    }

    function getVersion() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version(); 
    }

    // ngewithdraw semua dana yang telah diberikan oleh sender ke owner dan diberikan modifier onlyOwner agar keamanannya terjaga
    function withdraw() public onlyOwner(){
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0; //di reset jadi 0 
        }
        // reset array funders dengan panjangnya menjadi 0
        funders = new address[](0);
        // .call ngereturn boolean yang untuk send errornya harus menggunakan revert melalui keyword require
        (bool callSuccess,) = payable(msg.sender).call{value : address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }

    modifier onlyOwner(){
        if(msg.sender != i_owner) revert NotOwner();
        // artinya apabila conditioning diatas tidak berlaku, jalankan code selanjutnya pada function yang menggunakan modifier ini
        _;
    }
    
}