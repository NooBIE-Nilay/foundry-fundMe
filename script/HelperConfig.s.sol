// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "@FundMe/fundMe.sol";
import {MockV3Aggregator} from "@tests/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }
    NetworkConfig public activeNetworkConifg;

    constructor() {
        activeNetworkConifg = (block.chainid == 11155111)
            ? getSepoliaEthConifg()
            : (block.chainid == 1)
            ? getEthConifg()
            : getAnvilEthConfig();
    }

    function getSepoliaEthConifg() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }

    function getEthConifg() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
            });
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        // If activeNetworkConfig is already setted, directly return the adress
        if (activeNetworkConifg.priceFeed != address(0))
            return activeNetworkConifg;
        // We Create a mock contract and return its address.
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        return NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}
