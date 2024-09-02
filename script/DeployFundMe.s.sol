// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script{
    constructor() {}

    function run() external returns (FundMe){
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(AggregatorV3Interface(ethUsdPriceFeed));
        vm.stopBroadcast();

        return fundMe;
    }
}