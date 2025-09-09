//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;
import {Script, console} from "forge-std/Script.sol";
import {AutomatedRaffle} from "src/AutomatedRaffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {CreateSubscriptioninInteractions, FundSubscriptionInteractions, AddConsumer} from "script/Interactions.s.sol";

contract DeployRaffle is Script {
    // AutomatedRaffle automatedRaffle;
    // HelperConfig helperConfig;

    function run() public {
        deployContract();
    }

    function deployContract() public returns (AutomatedRaffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        if (config.subscriptionId == 0) {
            console.log("Subscription ID creation is progress");
            CreateSubscriptioninInteractions createSubID = new CreateSubscriptioninInteractions();
            (config.vrfCoordinator, config.subscriptionId) = createSubID
                .createSubscriptionID(config.vrfCoordinator);
            console.log("This is your ID", config.subscriptionId);
            FundSubscriptionInteractions fundingToSubscription = new FundSubscriptionInteractions();
            fundingToSubscription.fundSubscription(
                config.vrfCoordinator,
                config.subscriptionId,
                config.link
            );
            // ✅ persist in helperConfig
            helperConfig.setSubscriptionId(config.subscriptionId);
        }
        vm.startBroadcast();
        AutomatedRaffle automatedRaffle = new AutomatedRaffle(
            config.enteranceFee,
            config.keyHash,
            config.subscriptionId,
            config.gasLimit,
            config.vrfCoordinator
        );
        vm.stopBroadcast();
        AddConsumer addingConsumerToContract = new AddConsumer();
        addingConsumerToContract.addConsumer(
            config.vrfCoordinator,
            address(automatedRaffle),
            config.subscriptionId
        );
        console.log("my ID is ", config.subscriptionId);
        console.log("Adding consumer to contract", address(automatedRaffle));
        return (automatedRaffle, helperConfig);
    }
}
