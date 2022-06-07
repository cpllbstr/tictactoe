pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// 0xdAC17F958D2ee523a2206206994597C13D831ec7 - USDT
//
contract TicTacToe {
    struct Game {
        address[2] players;
        uint256[2] paid;
        address coin;
        uint256 bet;
        uint8 turn;
        uint8 winner;
        bool full;
        uint8[9] field;
    }

    uint256 game_num;

    mapping(uint256 => Game) games;
    mapping(address => bool) public allowed_coins;
    uint8[][] wins = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6]
    ];

    constructor() {
        // minimal bet is 1$
        allowed_coins[0xdAC17F958D2ee523a2206206994597C13D831ec7] = 1;
    }

    modifier checkTurn(uint256 curr_game_num) {
        Game memory _game = games[curr_game_num];
        require(_game != 0, "No such game");
        require(_game.full, "Not enough players!");
        require(msg.sender == _game.player[_game.turn - 1], "Not your turn");
        _;
    }

    modifier checkGame(uint256 curr_game_num) {
        Game memory _game = games[curr_game_num];
        require(_game != 0, "No such game");
        _;
    }

    function create_new_game(address _coin, uint256 _bet) returns (int256) {
        Game curr_game = Game({winner: 0, turn: 0, bet: _bet, full: false});
        curr_game.players[0] = msg.sender;

        if (!IERC20(coin).transferFrom(msg.sender, address(this), bet)) {
            revert("Cannot transfer from msg.sender!");
        }
        game_num += 1;
        games[game_num] = curr_game;
        return game_num;
    }

    function connect_to_game(int256 curr_game_num) {
        if (Game(games[curr_game_num]).full) {
            revert("No free slots!");
        }

        games[curr_game_num].players[1] = msg.sender;
        games[curr_game_num].full = true;

        if (
            !IERC20(coin).transferFrom(
                msg.sender,
                address(this),
                games[curr_game_num].bet
            )
        ) {
            revert("Cannot transfer from msg.sender!");
        }
    }

    function move(
        uint256 curr_game_num,
        uint8 x,
        uint8 y
    ) public checkTurn(curr_game_num) returns (uint8) {
        // returns
        // 0 - game is still going
        // 1 - player1 won
        // 2 - player2 won
        // 3 - draw
        uint8 position = y * 3 + x;

        if (0 < position && position > 8) revert("invalid position");

        Game memory curr_game = games[curr_game_num];
        if (curr_game.field[position] != 0) revert("already occupied");

        curr_game.field[position] = (curr_game.turn % 2) + 1;
        curr_game.turn += 1;

        uint8 win = whosWin(curr_game_num);

        if (win == 1 || win == 2) {
            curr_game.winner = win - 1;
        } else if (win == 3) {
            curr_game.winner = win;
        }

        games[curr_game_num] = curr_game;

        return win;
    }

    function withdraw(uint256 curr_game_num) checkGame(curr_game_num) {
        Game memory curr_game = games[curr_game_num];
        require(curr_game.winner != 0, "Game is still going");
        if (curr_game.winner == 0 || curr_game.winner == 1) {
            require(
                curr_game.player[curr_game.winner] == msg.sender,
                "You are not a winner"
            );
            require(
                curr_game.paid[curr_game.winner] < 2 * curr_game.bet,
                "Bounty was already paid"
            );

            curr_game.paid[curr_game.winner] += 2 * curr_game.bet;
            require(
                IERC20(curr_game.coin).transfer(
                    curr_game.players[curr_game.winner],
                    2 * curr_game.bet
                ),
                "Failed to transfer to winner"
            );
        }
        if (curr_game.winner == 3) {
            // Draw case
            for (uint8 i = 0; i < 2; i++) {
                if (
                    curr_game.players[i] == msg.sender &&
                    curr_game.paid[i] < curr_game.bet
                ) {
                    curr_game.paid[i] += curr_game.bet;
                    require(
                        IERC20(curr_game.coin).transfer(
                            curr_game.players[curr_game.winner],
                            curr_game.bet
                        ),
                        "Failed to transfer to drawer"
                    );
                }
            }
        }
    }

    function lookupGame(uint256 curr_game_num)
        public
        view
        checkGame(curr_game_num)
        returns (uint8[])
    {
        return games[curr_game_num].field;
    }

    function whosWin(curr_game_num) private view returns (uint8) {
        uint8[] memory _field = games[curr_game_num].field;
        for (uint8 i = 0; i < 8; i++) {
            uint8[] memory tt = wins[i];
            if (field[tt[0]] == field[tt[1]] && field[tt[1]] == field[tt[2]]) {
                return field[tt[0]];
            }
        }
        return 0;
    }
}
