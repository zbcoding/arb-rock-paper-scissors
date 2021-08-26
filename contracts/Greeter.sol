//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Greeter {
    string private greeting;
    uint private number;

    constructor(string memory _greeting) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
        number = 0;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }
    function getNumber() public view returns (uint) {
        return number;
    }
    function setNumber(uint _number) public {
        console.log("Changing number from '%s' to '%s'", number, _number);
        number = _number;
    }
    function incrementNumber() public {
        console.log("Incrementing the number");
        number++;
    }
}
