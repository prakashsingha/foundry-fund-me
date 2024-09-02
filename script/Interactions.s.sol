// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundMe(address recentlyDeployedContract) public {
        vm.startBroadcast();
        FundMe(payable(recentlyDeployedContract)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        // console.log("Funded the contract with %s", SEND_VALUE);
    }

    function run() external {
        address recentlyDeployedContract = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);

        fundFundMe(recentlyDeployedContract);
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function withdrawFundMe(address recentlyDeployedContract) public {
        vm.startBroadcast();
        FundMe(payable(recentlyDeployedContract)).withdraw();
        vm.stopBroadcast();
        console.log("Funded the contract with %s", SEND_VALUE);
    }

    function run() external {
        address recentlyDeployedContract = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(recentlyDeployedContract);
    }
}
