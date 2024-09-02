// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getEthToUsdPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 rate,,,) = priceFeed.latestRoundData();
        // ETH/USD rate in 18 digit
        return uint256(rate * 1e10);
    }

    function getUsdValue(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getEthToUsdPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;

        return ethAmountInUsd;
    }
}