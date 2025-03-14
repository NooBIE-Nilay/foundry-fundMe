//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {CurrencyConverter} from "@FundMe/currencyConverter.sol";

error FundMe__NotOwner();
error FundMe__CallFailed();
error FundMe__NotEnough();

contract FundMe {
    using CurrencyConverter for uint256;
    uint256 private constant MINIMUM_USD = 50 * 1e18;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;

    address private immutable i_owner;

    address private priceFeedAddress;

    constructor(address _priceFeedAddress) {
        priceFeedAddress = _priceFeedAddress;
        i_owner = msg.sender;
    }

    function fund() public payable {
        // Want to be able to set a min fund amt
        // require(msg.value.getConvertionRate() >= MINIMUM_USD, "Didn't send enough!");
        if (msg.value.getConvertedValue(priceFeedAddress) < MINIMUM_USD)
            revert FundMe__NotEnough();
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;

        // 1. How do we send ETH to this contract?-> Via Value Field in the Contract Field!
    }

    function getVersion() public view returns (uint256) {
        return CurrencyConverter.getVersion(priceFeedAddress);
    }

    function withdrawFunds() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint256 i = 0; i < fundersLength; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        //Reset the array with 0 elements
        s_funders = new address[](0);

        //Methods to send ETH.
        //transfer -> throws error when gas limit is reached
        // payable (msg.sender).transfer(address(this).balance);

        //send -> returns a bool about the sucess/failure
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"Sending Failed");

        //call -> LOW LEVEL FUNCTION -> returns call sucess and, data returned in bytes
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        // require(callSuccess,"Sending Failed");
        if (!callSuccess) revert FundMe__CallFailed();
    }

    //Middlewares
    modifier onlyOwner() {
        // require(msg.sender==i_owner,"Sender Not Owner");
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _; // next();
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    //Getters
    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
