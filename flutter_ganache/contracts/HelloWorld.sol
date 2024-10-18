// SPDX-License-Identifier: MIT
pragma solidity >0.5.0 <0.9.0;

contract HelloWorld {
    string private message;

    constructor() public {
        message = "Hello World!";
    }

    function getMessage() public view returns (string memory) {
        return message;
    }

    function setMessage(string memory newMessage) public {
        message = newMessage;
    }
}
