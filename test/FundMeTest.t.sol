// SPDX-License-Identifer: MIT

pragma solidity 0.8.19;
import {Test, Console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimumDollarIsFive() external {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() external {
        assertEq(fundMe.i_owner, address(this));
    }
}
