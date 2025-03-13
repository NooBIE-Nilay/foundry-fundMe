// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "@FundMe/fundMe.sol";
import {DeployFundMe} from "@scripts/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address immutable USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant INITIAL_BAL = 10 ether;

    function setUp() external {
        DeployFundMe deployedFundMe = new DeployFundMe();
        fundMe = deployedFundMe.run();
        vm.deal(USER, INITIAL_BAL);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        assertEq(fundMe.getVersion(), (block.chainid == 1) ? 6 : 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdates() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdrawFunds();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Tests can be broken to 3 stages : Arrange-> Act ->  Assert

        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdrawFunds();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingFundMeBalance + endingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFunders() public funded {
        //Arrange
        uint8 noOfFunders = 10;
        uint8 startingIndex = 1;
        for (uint160 i = startingIndex; i < noOfFunders; i++) {
            hoax(address(i), INITIAL_BAL);
            fundMe.fund{value: SEND_VALUE}(); // hoax-> prank and deal
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdrawFunds();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingFundMeBalance + endingOwnerBalance
        );
    }
}
