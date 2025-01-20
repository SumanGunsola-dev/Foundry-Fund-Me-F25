// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
// Deploy mocks when we are on a local anvil chain
// Keep track of contract address across different chains
// Sepolia ETH/USD
// Mainnet ETH/USD
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on anvil ,we deploy mocks
    // Otherwise we grab the existing address from the live network
    NetWorkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    struct NetWorkConfig {
        address priceFeed; //ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetWorkConfig memory) {
        // Price feed address
        NetWorkConfig memory SepoliaConfig = NetWorkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return SepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetWorkConfig memory) {
        // Price feed address

        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // 1. Deploy the mocks
        // 2. Return the mock address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetWorkConfig memory anvilConfig = NetWorkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
