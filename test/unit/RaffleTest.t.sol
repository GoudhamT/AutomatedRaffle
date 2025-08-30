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
    uint256 constant STARTING_BALANCE = 10 ether;

    event Raffle__RaffleEntered(address indexed player);

    function setUp() external {
        DeployRaffle rafflecontract = new DeployRaffle();
        (automatedRaffle, helperConfig) = rafflecontract.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        enteranceFee = config.enteranceFee;
        keyHash = config.keyHash;
        subscriptionId = config.subscriptionId;
        gasLimit = config.gasLimit;
        vrfCoordinator = config.vrfCoordinator;
        vm.deal(PLAYER, STARTING_BALANCE);
    }

    function testRaffleStateIsOpen() public view {
        assert(automatedRaffle.getState() == AutomatedRaffle.RaffleState.OPEN);
    }

    function testVerifyEnteranceFeeModifier() external {
        vm.prank(PLAYER);
        automatedRaffle.enterRaffle{value: enteranceFee}();
    }

    function testVerifyEnteranceFeeModifierExpectError() external {
        vm.prank(PLAYER);
        vm.expectRevert("Raffle Entry denied");
        automatedRaffle.enterRaffle{value: 0}();
    }

    function testPlayerLength() external {
        vm.prank(PLAYER);
        automatedRaffle.enterRaffle{value: enteranceFee}();
        assert(automatedRaffle.getPlayersLength() == 1);
    }

    function testPlayerAddressIsMatching() external {
        vm.prank(PLAYER);
        automatedRaffle.enterRaffle{value: enteranceFee}();
        assert(PLAYER == automatedRaffle.getPlayer(0));
    }

    function testRaffleEnteredEventCalling() external {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(automatedRaffle));
        emit Raffle__RaffleEntered(PLAYER);
        automatedRaffle.enterRaffle{value: enteranceFee}();
    }

    function testUpKeepNeededPassedCondition() external {
        vm.prank(PLAYER);
        automatedRaffle.enterRaffle{value: enteranceFee}();
        (bool upKeepNeeded, ) = automatedRaffle.checkUpkeep("");
        assert(upKeepNeeded == false);
    }

    function testUpKeepNeededEveryConditionPassed() public {
        vm.prank(PLAYER);
        automatedRaffle.enterRaffle{value: enteranceFee}();
        uint256 timeNow = automatedRaffle.getTime();
        vm.warp(block.timestamp + automatedRaffle.INTERVAL() + 1);
        vm.roll(1);
        (bool upKeepNeeded, ) = automatedRaffle.checkUpkeep("");
        assert(upKeepNeeded);
    }
}
