// SPDX-License-Identifer: MIT

pragma solidity 0.8.19;
import {Test} from "forge-std/Test.sol";
//import {Console} from "forge-std/console.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address User = makeAddr("User");
    uint256 constant STARTING_AMOUNT = 10e18;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() external {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() external {
        //assertEq(fundMe.getOwner, msg.sender);
    }

    function testAggregatorVersion() external {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsLessEth() external {
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(User);
        vm.deal(User, STARTING_AMOUNT);
        fundMe.fund{value: STARTING_AMOUNT}();
        _;
    }

    function testFundsUpdatesDataStructure() external funded {
        uint256 amount = fundMe.getAddressToAmountFunded(User);
        assertEq(amount, STARTING_AMOUNT);
    }

    function testFunderIsAddedToFundersArray() external funded {
        assertEq(fundMe.getFunder(0), User);
    }

    function testOnlyOwnerCanWithdraw() external funded {
        vm.expectRevert();
        vm.prank(User);
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() external funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFunders() external {
        uint160 numberOfFunders = 10;
        for (uint160 i = 1; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_AMOUNT);
            fundMe.fund{value: STARTING_AMOUNT}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }
}
