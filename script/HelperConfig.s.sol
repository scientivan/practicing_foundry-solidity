// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    uint8 public constant ETH_DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    struct NetworkConfig {
        address priceFeed;
    }

    mapping(uint256 => NetworkConfig) internal networkConfigs;

    NetworkConfig public activeNetworkConfig;

    constructor() {
        // Inisialisasi semua network yang kamu dukung
        // anvil local blockchain
        if (block.chainid == 31337) {
            activeNetworkConfig = getAnvilEthConfig();
        } else {
            networkConfigs[11155111] = NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // sepolia
            });

            networkConfigs[1] = NetworkConfig({
                priceFeed: 0x5147eA642CAEF7BD9c1265AadcA78f997AbB9649 // mainnet eth
            });

            activeNetworkConfig = networkConfigs[block.chainid];
        }
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            ETH_DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed) // placeholder atau mock nanti kamu deploy sendiri
            // kita harus bikin mock dlu (fake account with fake balance)
            // ngereturn address dari mock tersebut
        });
        return anvilConfig;
    }
}

// pragma solidity ^0.8.13;

// import {FundMe} from "../src/FundMe.sol";
// import {DeployFundMe} from "../script/DeployFundMe.s.sol";

// contract HelperConfig {
//     NetworkConfig public activeNetworkConfig;

//     struct NetworkConfig {
//         address priceFeed;
//     }

//     constructor() {
//         // kalok chainidnya adalah chain id nya sepoliaeth, maka return pricefeednya sepoliaeth
//         if (block.chainid == 11155111) {
//             activeNetworkConfig = getSepoliaEthConfig();
//         }
//         // kalok chainidnya bukan chain id nyasepoliaeth, maka return pricefeednya anvil
//         else {
//             activeNetworkConfig = getAnvilEthConfig();
//         }
//     }
//     // jaringan testnet sepolia (punya chainlink, jadi bisa langsung ambil priceFeed yang udah ada dan ga harus buat mock)
//     function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
//         NetworkConfig memory sepoliaConfig = NetworkConfig({
//             priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
//         });
//         return sepoliaConfig;
//     }

//     // jaringan local testnet anvil (Karena Anvil tidak punya Chainlink, kamu perlu deploy price feed mock sendiri, misalnya MockV3Aggregator.)
//     function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
//         // price feed address
//     }
// }
