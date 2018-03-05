pragma solidity ^0.4.11;

contract Casino {
   address owner;
   uint minimumBet;
   uint totalBet;
   uint numberOfBets;
   uint maxAmountOfBets = 100;
   address[] players;

   // A struct is essentially an object in javascript and a mapping is like
   // an array (think of hash tables).

   struct Player {
     uint amountBet;
     uint numberSelected;
   }

   mapping(address => Player) playerInfo;

   // The mapping called playerInfo allows you to use the player's address
   // as the "key". So then the Player struct contains an address, the
   // amount bet and number selected.

   // The following function is to determine the minimum bet a player can
   // make. It is also the constructor because it takes the same name
   // as the contract.

   function Casino(uint _minimumBet){
      owner = msg.sender;
      if(_minimumBet != 0) minimumBet = _minimumBet;
   }

   // The following function is to bet for a number between 1 and 10 inclusive.
   // "Payable" is a modifier which says that if the player wants to execute
   // this function, the player needs to pay ether.

   function bet(uint number) payable{
     assert(checkPlayerExists(msg.sender) == false);
     assert(number >= 1 && number <= 10);
     assert(msg.value >= minimumBet);

     // The assert() function is essentially an if that must be true. The
     // function will stop if the condition comes back false.
     // checkPlayerExists(msg.sender) checks if the player has played already.
     // msg.sender and msg.value are values that the player defines when they
     // execute the contract. msg.sender is his address and msg.value is how
     // much ether he paid.

     playerInfo[msg.sender].amountBet = msg.value;
     playerInfo[msg.sender].numberSelected = number;
     numberOfBets += 1;
     players.push(msg.sender);
     totalBet += msg.value;

     // This will generate a winner number if the number of bets is bigger
     // than or equal to the maximum:

     if(numberOfBets >= maxAmountOfBets) generateNumberWinner();
   }

   // The following function checks if the user has played already.

   function checkPlayerExists(address player) returns(bool){
     for(uint i = 0; i < players.length; i++){
       if(players[i] == player) return true;
     }
     return false;
   }

   // The following function generates a ""random"" number between 1 and 10
   // for the winner of the game LMAOOOO

   function generateNumberWinner(){
      uint numberGenerated = block.number % 10 + 1;
      distributePrizes(numberGenerated);
   }

   // The following function distributes the ether to the winners depending
   // on the total amount of bets.

   function distributePrizes(uint numberWinner){
     address[100] memory winners;
     // The above creates a temporary array called winners with fixed size
     // by chcking if the player's numberSelected is the numberWinner.
     // The winners array will get deleted once the function executes.
     uint count = 0;
     // The above is the count for the array of winners.

     for(uint i = 0; i < players.length; i++){
       address playerAddress = players[i];
       if(playerInfo[playerAddress].numberSelected == numberWinner){
         winners[count] = playerAddress;
         count++;
       }
       delete playerInfo[playerAddress];
     }
     players.length = 0
     // The above will delete the players' array.
     uint winnerEtherAmount = totalBet / winners.length
     // The above will give you how much ether each winner will get.
     for(uint j = 0; j < count; j++){
       if (winners)[j] != address(0))
       // The above makes sure the address in the fixed array isn't empty.
          winners[j].transfer(winnerEtherAmount);
     }
   }

   // As insurance, the below is a fallback function to make sure the
   // ether someone sends to the contract doesn't get lost.

   function() payable{}

   function kill(){
      if(msg.sender == owner)
         selfdestruct(owner);
   }
}
