// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    function fundFundMe(address mostRecentlyDeployed) public {
        uint256 SEND_VALUE = 0.01 ether;
        vm.deal(address(this), SEND_VALUE);
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
    }

    function run() external {
        address fundMe = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(fundMe);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.prank(FundMe(payable(mostRecentlyDeployed)).getOwner());
        FundMe(payable(mostRecentlyDeployed)).withdraw();
    }

    function run() external {
        address fundMe = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        withdrawFundMe(fundMe);
        vm.stopBroadcast();
    }
}
