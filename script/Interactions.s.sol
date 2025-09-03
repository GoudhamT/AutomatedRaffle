//SPDX-License-Ientifier:MIT

pragma solidity 0.8.19;

import {HelperConfig, RaffleConstants} from "script/HelperConfig.s.sol";
import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscriptioninInteractions is Script {
    function run() public {
        createSubscriptionIdUsingConfig();
    }

    function createSubscriptionIdUsingConfig()
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
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(_vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        console.log("generated subscription ID is ", subId);
        console.log("for VRF coordinator", _vrfCoordinator);
        return (_vrfCoordinator, subId);
    }
}

contract FundSubscriptionInteractions is Script, RaffleConstants {
    uint256 public FUNDING_AMOUNT = 3 ether;

    function run() public {
        fundSubscriptionUsingConfig();
    }

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().link;
        fundSubscription(vrfCoordinator, subscriptionId, linkToken);
    }

    function fundSubscription(
        address _vrfCoordinator,
        uint256 _subId,
        address _link
    ) public {
        if (block.chainid == LOCAL_CHAIN_ID) {
            VRFCoordinatorV2_5Mock(_vrfCoordinator).fundSubscription(
                _subId,
                FUNDING_AMOUNT
            );
        } else {
            vm.startBroadcast();
            LinkToken(_link).transferAndCall(
                _vrfCoordinator,
                FUNDING_AMOUNT,
                abi.encode(_subId)
            );
            vm.stopBroadcast();
        }
    }
}

contract AddConsumer is Script {
    function run() public {
        address recentDeployedContract = DevOpsTools.get_most_recent_deployment(
            "AutomatedRaffle",
            block.chainid
        );
        addConsumerUsingConfig(recentDeployedContract);
    }

    function addConsumerUsingConfig(address _recentlyDeployedContract) public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subId = helperConfig.getConfig().subscriptionId;
        addConsumer(vrfCoordinator, _recentlyDeployedContract, subId);
    }

    function addConsumer(
        address _vrfCoordinator,
        address _deployedConract,
        uint256 _subId
    ) public {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(_vrfCoordinator).addConsumer(
            _subId,
            _deployedConract
        );
        vm.stopBroadcast();
    }
}
