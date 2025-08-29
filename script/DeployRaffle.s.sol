//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;
import {Script} from "forge-std/Script.sol";
import {AutomatedRaffle} from "src/AutomatedRaffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployRaffle is Script {
    // AutomatedRaffle automatedRaffle;
    // HelperConfig helperConfig;

    function run() public {}

    function deployContract() public returns (AutomatedRaffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        vm.startBroadcast();
        AutomatedRaffle automatedRaffle = new AutomatedRaffle(
            config.enteranceFee,
            config.keyHash,
            config.subscriptionId,
            config.gasLimit,
            config.vrfCoordinator
        );
        vm.stopBroadcast();

        return (automatedRaffle, helperConfig);
    }
}
