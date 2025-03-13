//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";

//Library

library CurrencyConverter {
    function getPrice(
        address priceFeedAddress
    ) internal view returns (uint256) {
        // ABI = AggregateV3Interface
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // price => price of 1 ETH in terms of USD
        return uint(price * 1e10); // price*10^10
    }

    function getVersion(
        address priceFeedAddress
    ) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        return priceFeed.version();
    }

    function getConvertedValue(
        uint256 ethAmount,
        address priceFeedAddress
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeedAddress);
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUSD;
    }
}
