//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Script} from "forge-std/Script.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

abstract contract RaffleConstants {
    uint256 public constant SEPLOIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
    uint96 public constant MOCK_BASEFEE = 0.25 ether;
    uint96 public constant MOCK_GASPRICE = 1e9;
    int256 public constant MOCK_GASWEI_LINK = 4e15;
}

contract HelperConfig is RaffleConstants, Script {
    struct NetworkConfig {
        uint256 enteranceFee;
        bytes32 keyHash;
        uint256 subscriptionId;
        uint32 gasLimit;
        address vrfCoordinator;
        address link;
    }

    NetworkConfig public localNetwork;

    function getConfig() public returns (NetworkConfig memory) {
        return getNetworkfromConfig(block.chainid);
    }

    function getNetworkfromConfig(
        uint256 _chainID
    ) public returns (NetworkConfig memory) {
        if (_chainID == SEPLOIA_CHAIN_ID) {
            return getSepoliaConfig();
        } else if (_chainID == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilConfig();
        } else {
            revert("Network not supported");
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                enteranceFee: 0.01 ether,
                keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 0,
                gasLimit: 7544857,
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
            });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock mock = new VRFCoordinatorV2_5Mock(
            MOCK_BASEFEE,
            MOCK_GASPRICE,
            MOCK_GASWEI_LINK
        );
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();
        localNetwork = NetworkConfig({
            enteranceFee: 0.01 ether,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0,
            gasLimit: 7544857,
            vrfCoordinator: address(mock),
            link: address(linkToken)
        });
        return localNetwork;
    }
}
