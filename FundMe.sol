// SPDX-License-Indentifier: MIT;

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundeMe{
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5e18;
    address public ownerAddress;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) addressToFund;

    constructor(){
        ownerAddress = msg.sender;
    }

    function fund() public payable{
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You not able to transfer this amount of eth, because minimum USD you need to transfer is $5.");
        funders.push(msg.sender);
        addressToFund[msg.sender] = addressToFund[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner{
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToFund[funder] = 0;
        }
        funders = new address[](0);

        // three different way to withdraw the funds

        // transfer - if gas grater than 23000 throw error
        // payable(msg.sender).transfer(address(this).balance);

        // send - if gas grater than 23000 return boolean
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"Transaction fails.");

        // call
        (bool callSuccess,) =payable(msg.sender).call{value : address(this).balance}("");
        require(callSuccess,"Transaction fails.");
        // ("") -> if you want to call some function that put that function in this bracket here we don't need to call any function so we leave it blank
        // this call fnuction return 2 variables 1st on is success status and 2nd is data -> when we call function at that time this function return some data so grab that data this variable is use


    }

    modifier onlyOwner() {
        // require(msg.sender == ownerAddress,"Sender is not owner");
        if(msg.sender != ownerAddress){ revert NotOwner(); }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    // if some person send eth without calling fund function 

    // here, this problem is solve with a use of this two function this function call by default so inthis function we can call the fund function manually

    // receive - function type - this is call when transaction has no data including in it
    // fallback - function type - over come the flaws in the receive function means this function is call when the data is assostiated with the transaction
}