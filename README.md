# Ruby-Chess

A command line game of chess, written in Ruby.

## Usage

A simple 'ruby chess.rb' will launch a game, or optionally pass it "random" or "chess960" as an argument for [Chess960](https://en.wikipedia.org/wiki/Chess_960) starting positions.

## Implementation

A basic game loop alternates players. On each move, a number of checks are performed:
1. Does the piece belong to the player?
2. Is the destination move a valid move for that piece?
3. Is the destination on the board?
4. Is the path to the destination blocked, or is the destination blocked by a piece of the same color?
5. Will that move place the King in check?

Exceptions are raised and rescued to control valid movements.

To determine check, the same validations are performed to see if each of the opponent's pieces can make a valid move against the player's King.

To determine checkmate, the board is duplicated and the next turn is simulated on the fake board. If no exceptions are raised, there is a valid move that can either move the King out of check, block the threatening piece, or capture the threatening piece. Since the Board class keeps track of all the threats against a player's King, we know how many threats exist. If a King is in check from two pieces, the only possible escape is moving the king, which reduces the amount of simulations the game has to run.

There is no AI player currently, but one can be made as long as it inherits from Player and implements the get_move method.

## To Do

* Allow input in [algebraic notation](https://en.wikipedia.org/wiki/Algebraic_chess_notation), wherein only the piece type and destination is given, and the piece's starting location is inferred.
* Write a basic AI player
