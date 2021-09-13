// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../solidity-stringutils/src/strings.sol";
//https://github.com/Arachnid/solidity-stringutils


contract RockPaperScissors {
  using strings for *;
  using SafeMath for uint256;
  //1 = rock 2 = paper 3 = scissors
  enum Choice {None, Rock, Paper, Scissors}
  bytes32 private encrypted1;
  bytes32 private encrypted2; //encrypted choice
  address payable public owner; //from solidity >0.8 payable explicit not needed
  address payable private address1;
  address payable private address2;
  uint256 address1bet;
  uint256 address2bet;
  string player1Move;
  string player2Move;
  uint256 time;
  //add event for wager
  //add event for choice reveal
  
  //uint256 timestart;
  //uint256 constant timeout = 30 minutes;

  event game(address indexed _player1,
  address indexed _player2, 
  string indexed _winAddress, 
  int256 _totalAmountBet);

	//constructor(uint256 total) public { for older solidity
  constructor() payable {
  owner = payable(msg.sender);
  }

  //modifiers
  modifier notAlreadyBet() {
        require(msg.sender != address1 && msg.sender != address2);
        _;
    }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function withdraw() public onlyOwner {
    // get the amount of Ether stored in this contract
    uint256 contractAmount = address(this).balance - address1bet - address2bet;
    (bool success,) = owner.call{value: contractAmount}("");
    require(success, "Failed to send Ether");
  }

  function transfer(address payable _to, uint _amount) public {
    // Note that "to" is declared as payable
    (bool success,) = _to.call{value: _amount}("");
    require(success, "Failed to send Ether");
  }

  function wager(bytes32 _encryptedChoice) public payable notAlreadyBet {
    if (address1 == address(0x0) && _encryptedChoice == 0x0) {
      address1 = payable(msg.sender);
      address1bet = msg.value;
      encrypted1 = _encryptedChoice;
    }
    else if (address2==address(0x0) && _encryptedChoice == 0x0) {
      require(msg.value >= address1bet, "Bet must be at least as much as player 1's bet"); //bets need to at least match in amounts
      address2 = payable(msg.sender);
      address2bet = msg.value;
      encrypted2 = _encryptedChoice;
    }
    //todo: add wager event
    time = block.timestamp; //set time of last wager
  }

  modifier betSet() {
    require(address1 == address(0x0) ||
            address2 == address(0x0) ||
            encrypted1 == 0x0        ||
            encrypted2 == 0x0,
            "Both players have not sent in their bets");
    _;
  }
  //clear choice = Choice + random gen password e.g. Scissors-0a98s7df07asdf0789
  //front end will hash this for user when they make bet
  //to reveal later they supply this in clear text and the contract checks the hashes
  function reveal(string memory clearChoice) public betSet returns (Choice) {
    require(msg.sender == address1 || msg.sender == address2, "Address not player");
    bytes32 encryptedChoice = sha256(abi.encodePacked(clearChoice));
    if (encryptedChoice == encrypted1 && msg.sender == address1) {
      //save player1 move
      player1Move = clearChoice;
    }
    else if (encryptedChoice == encrypted2 && msg.sender == address2) {
      //save player2 move
      player2Move = clearChoice;
    }
    else if (msg.sender == address1) {
      //save player1 move as None
      player1Move = "None";
    }
    else if (msg.sender == address2) {
      //save player2 move as None
      player2Move = "None";
    }
    else
      //save/return None
      player1Move = "None";
      player2Move = "None";
  }

  //todo: rewrite this function
  function callGame() external {
    
    string memory winAddress;
    uint256 winAmount = 99*(address1bet + address2bet)/100; //99% of total, 1% fee
    require(address1bet == address2bet, "Bet amounts do not match");
     
    
    //logic of rock paper scissors winning/ties
    if (player1Move.toSlice().rfind("-".toSlice()) 
    .equals(player2Move.toSlice().rfind("-".toSlice()))) {
    winAddress = "Tie";
    //pay back both addresses' bet with each contributing to fee
    transfer(address1, (995*address1bet)/1000);
    transfer(address2, (995*address2bet)/1000);
    }
    /*var s = "A B C B D".toSlice();
    s.rfind("B".toSlice()); // "A B C B"*/
    if (player1Move.toSlice().contains("Rock".toSlice()) 
    && player2Move.toSlice().contains("Paper".toSlice())) { //rock, paper
      winAddress = toAsciiString(address2);
      transfer(address2, (winAmount));
    } 
    if (player1Move.toSlice().contains("Rock".toSlice()) 
    && player2Move.toSlice().contains("Scissors".toSlice())) { //rock, scissors
      winAddress = toAsciiString(address1);
      transfer(address1, (winAmount));
    } 
    if (player1Move.toSlice().contains("Paper".toSlice()) 
    && player2Move.toSlice().contains("Rock".toSlice())) { //paper, rock
      winAddress = toAsciiString(address1);
      transfer(address1, (winAmount));
    }
    if (player1Move.toSlice().contains("Paper".toSlice()) 
    && player2Move.toSlice().contains("Scissors".toSlice())) { //paper, scissors
      winAddress = toAsciiString(address2);
      transfer(address2, (winAmount));
    }  
    if (player1Move.toSlice().contains("Scissors".toSlice()) 
    && player2Move.toSlice().contains("Rock".toSlice())) { //scissors, rock
      winAddress = toAsciiString(address2);
      transfer(address2, (winAmount));
    } 
    if (player1Move.toSlice().contains("Scissors".toSlice()) 
    && player2Move.toSlice().contains("Paper".toSlice())) { //scissors, paper
      winAddress = toAsciiString(address1);
      address1.transfer(winAmount);
    } 
    //event
    uint256 totalAmount = address1bet + address2bet;
    emit game(address1, address2, winAddress, int256(totalAmount));

    reset();

  }
  
  function reset() private {
    address1 = payable(address(0x0));
    address2 = payable(address(0x0));
    address1bet = 0;
    address2bet = 0;
    encrypted1 = 0x0;
    encrypted2 = 0x0;
    time = 0;
  }

  function timeOut() external {
    if (time > 0 && block.timestamp > time + 4 hours) {
      //return player money
      address1.transfer(address1bet);
      address2.transfer(address2bet);
      //reset the game
      reset();
    }
  }

  //helper functions  
  function toAsciiString(address x) internal pure returns (string memory) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
        bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
        bytes1 hi = bytes1(uint8(b) / 16);
        bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
        s[2*i] = char(hi);
        s[2*i+1] = char(lo);            
    }
    return string(s);
  }

  function char(bytes1 b) internal pure returns (bytes1 c) {
    if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
    else return bytes1(uint8(b) + 0x57);
  }

}//end contract


