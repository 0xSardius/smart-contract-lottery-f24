// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions



pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title Raffle sample contract
 * @author 0xSardius
 * @notice This is a simple raffle contract
 * @dev Implements Chainlink VRF 2.5
 */

contract Raffle is VRFConsumerBaseV2Plus{

    /* Errors */
    // When working with errors, use if statements. Custom errors are more gas efficient than require statements
    error Raffle__SendMoreToEnterRaffle();
    error Raffle__NotEnoughTimePassed();

    /* State Variables */
    uint8 private constant NUM_WORDS = 1;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint256 private immutable i_entranceFee;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address payable[] private s_players;
    // @dev interval is in seconds
    uint256 private immutable i_interval;
    uint256 private s_lastTimeStamp;
    

    /* Events */
    event RaffleEntered(address indexed player);

    /* Constructor */
    /**
        * @param vrfCoordinator: The address of the VRF Coordinator
     */ 
    constructor(uint256 entranceFee, uint256 interval, address vrfCoordinator, bytes32 gasLane, uint256 subscriptionId, uint32 callbackGasLimit) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() public payable {
        // Not gas efficient because of stored string
        // require(msg.value >= i_entranceFee, "Not enough ETH sent!");
        // Below takes long to compile
        // require(msg.value >= i_entranceFee, SendMoreToEnterRaffle());
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() public {
        // check to see if enough time has passed
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }
        // Get our random Number
        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );

    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal virtual override{}

    function closeRaffle() public {
        // Close the raffle
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}