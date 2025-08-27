//SPDX-License-identifier:MIT

pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

error Raffle__StateisnotOpen();
error Raffle__TimehasNotPassed(uint256 time);

contract AutomatedRaffle is VRFConsumerBaseV2Plus {
    /* Type Declarations */
    enum RaffleState {
        OPEN,
        CALCULATING
    }
    /* State Variabels */
    uint256 private constant INTERVAL = 1 hours;
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_enteranceFee;
    bytes32 private immutable i_keyhash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_gasLimit;
    uint256 private s_processTime;
    RaffleState private s_raffleState;
    address payable[] private s_players;
    uint256 private s_number;

    /*Events */
    event Raffle__RaffleEntered(address indexed player);

    constructor(
        uint256 _enteranceFee,
        bytes32 _keyHash,
        uint256 _subscriptionId,
        uint32 _gasLimit,
        address _vrfCoordinator
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        i_enteranceFee = _enteranceFee;
        i_keyhash = _keyHash;
        i_subscriptionId = _subscriptionId;
        i_gasLimit = _gasLimit;
        s_processTime = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    /*Modifiers */
    modifier verifyEnteranceFee() {
        require(msg.value > i_enteranceFee, "Raffle Entry denied");
        _;
    }

    function enterRaffle() public payable verifyEnteranceFee {
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__StateisnotOpen();
        }
        s_players.push(payable(msg.sender));
        emit Raffle__RaffleEntered(msg.sender);
    }

    function pickWinner() public {
        if ((block.timestamp - s_processTime) < INTERVAL) {
            revert Raffle__TimehasNotPassed((block.timestamp - s_processTime));
        }

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyhash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATION,
                callbackGasLimit: i_gasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });

        s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] calldata randomWords
    ) internal override {
        s_number = randomWords[0];
    }

    /* view functions */
    function getPlayer(uint256 _index) external view returns (address) {
        return s_players[_index];
    }

    function getPlayersLength() external view returns (uint256) {
        return s_players.length;
    }

    function getState() external view returns (RaffleState) {
        return s_raffleState;
    }

    function getEnteranceFee() external view returns (uint256) {
        return i_enteranceFee;
    }

    function getTime() external view returns (uint256) {
        return s_processTime;
    }

    function getNumber() external view returns (uint256) {
        return s_number;
    }
}
