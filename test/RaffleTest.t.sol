//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {AutomatedRaffle} from "src/AutomatedRaffle.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract RaffleTest is Script {
    AutomatedRaffle automatedRaffle;
    HelperConfig helperConfig;
    uint256 enteranceFee;
    bytes32 keyHash;
    uint256 subscriptionId;
    uint32 gasLimit;
    address vrfCoordinator;
    address PLAYER = makeAddr("player");

    function setUp() public {
        DeployRaffle rafflecontract = new DeployRaffle();
        (automatedRaffle, helperConfig) = rafflecontract.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        enteranceFee = config.enteranceFee;
        keyHash = config.keyHash;
        subscriptionId = config.subscriptionId;
        gasLimit = config.gasLimit;
        vrfCoordinator = config.vrfCoordinator;
    }

    function testRaffleStateIsOpen() public view {
        assert(automatedRaffle.getState() == AutomatedRaffle.RaffleState.OPEN);
    }
}
