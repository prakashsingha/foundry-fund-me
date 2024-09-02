// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = vm.addr(1);
    uint256 constant INITIAL_BALANCE = 100 ether;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        /**
         * Network: Sepolia
         * Data Feed: ETH/USD
         * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
         */
        // fundMe = new FundMe(AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306));
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, INITIAL_BALANCE);
    }

    function testMinimumAmountIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testRejectFundingWithoutBalance() public {
        vm.expectRevert();
        fundMe.fund(); // 0 value
    }

    function testMinimumFundingAmount() public {
        vm.expectRevert("Amount must be minimum of 5 USD");
        fundMe.fund{value: 0.001 ether}();
    }

    function testFundedAmountWithFunder() public funded {
        uint256 fundedAmount = fundMe.getAddressToAmountFunded(USER);
        assertEq(fundedAmount, SEND_VALUE);
    }

    function testFundersArray() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawByASingleFunder() public funded {
        // Arrange
        address owner = fundMe.getOwner();
        address fundMeContract = address(fundMe);

        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = fundMeContract.balance;

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(owner);
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = owner.balance;
        uint256 endingFundMeBalance = fundMeContract.balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawByMultipleFunders() public funded {
        // Arrange
        uint160 numOfFunders = 10;
        uint160 startingIndex = 1;

        address owner = fundMe.getOwner();
        address fundMeContract = address(fundMe);

        for (uint160 i = startingIndex; i < numOfFunders; i++) {
            // vm.prank()
            // vm.deal()
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = fundMeContract.balance;

        // Act
        vm.prank(owner);
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = owner.balance;
        assert(fundMeContract.balance == 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    //
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
}
