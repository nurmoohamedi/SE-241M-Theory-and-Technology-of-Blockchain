// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract HelloWorld {
    string public message;

    // Constructor to initialize the message
    constructor() {
        message = "Hello, World!";
    }

    // Function to update the message
    function setMessage(string memory newMessage) public {
        message = newMessage;
    }

    // Function to read the message
    function getMessage() public view returns (string memory) {
        return message;
    }
}
