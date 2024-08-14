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

// SPDC-License-Identifier: MIT

pragma solidity ^0.8.19;

/**
 * @title Raffle sample contract
 * @author 0xSardius
 * @notice This is a simple raffle contract
 * @dev Implements Chainlink VRF 2.5
 */

contract Raffle {

    /* Errors */
    // When working with errors, use if statements. Custom errors are more gas efficient than require statements
    error Raffle__SendMoreToEnterRaffle();

    /* State Variables */
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;

    /* Events */
    event RaffleEntered(address indexed player);

    /* Constructor */
    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
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
        // Pick the winner
    }

    function closeRaffle() public {
        // Close the raffle
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}