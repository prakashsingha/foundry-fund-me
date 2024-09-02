// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract IntegrationTest is Test {
    FundMe fundMe;
    address USER = vm.addr(1);
    uint256 constant INITIAL_BALANCE = 100 ether;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, INITIAL_BALANCE);
    }

    function testUserInteractions() public {
        FundFundMe fundingContract = new FundFundMe();
        fundingContract.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawContract = new WithdrawFundMe();
        withdrawContract.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
