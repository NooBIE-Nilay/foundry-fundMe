// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "@FundMe/fundMe.sol";
import {DeployFundMe} from "@scripts/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "@scripts/Interactions.s.sol";

contract FundMeInteractionTest is Test {
    FundMe fundMe;

    address immutable USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant INITIAL_BAL = 10 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, INITIAL_BAL);
        vm.deal(address(fundMe), INITIAL_BAL);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
