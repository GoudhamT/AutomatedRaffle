//SPDX-License-Ientifier:MIT

pragma solidity 0.8.19;

import {HelperConfig} from "script/HelperConfig.s.sol";
import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract CreateSubscriptioninInteractions {
    function run() public {}

    function createSubscriptionIdfromConfig()
        public
        returns (address, uint256)
    {
        HelperConfig helperConfig = new HelperConfig();
        // HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        (, uint256 subID) = createSubscriptionID(vrfCoordinator);
        return (vrfCoordinator, subID);
    }

    function createSubscriptionID(
        address _vrfCoordinator
    ) public returns (address, uint256) {
        uint256 subId = VRFCoordinatorV2_5Mock(_vrfCoordinator)
            .createSubscription();
        console.log("generated subscription ID is ", subId);
        console.log("for VRF coordinator", _vrfCoordinator);
        return (_vrfCoordinator, subId);
    }
}
