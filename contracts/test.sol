pragma solidity ^0.8.0;

contract TicTacToe {
    address[] players;

    bool full = false;

    uint8 turn = 1;
    uint8 winner = 0;

    uint8[] field = new uint8[](9);
    uint8[][] tests = [
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
        players.push(msg.sender);
    }

    modifier checkFull() {
        require(!full, "No free slots!");
        _;
    }

    function addPlayer(address player) public checkFull {
        players.push(player);
        full = true;
    }

    modifier checkTurn() {
        require(msg.sender == players[turn - 1], "not your turn");
        _;
    }

    function move(uint8 x, uint8 y) public checkTurn {
        uint8 position = y * 3 + x;

        if (0 < position && position > 8) revert("invalid position");

        if (field[position] != 0) revert("already occupied");

        field[position] = turn;
        turn = 3 - turn;
    }

    function concatenate(string memory a, string memory b)
        public
        pure
        returns (string memory)
    {
        return string(bytes.concat(bytes(a), bytes(b)));
    }

    function lookBoard() private view returns (string memory) {
        string memory board = "";
        for (uint8 y = 0; y < 3; y++) {
            for (uint8 x = 0; x < 3; x++) {
                if (field[y * 3 + x] == 1) {
                    board = concatenate(board, "X");
                } else if (field[y * 3 + x] == 2) {
                    board = concatenate(board, "O");
                } else {
                    board = concatenate(board, "-");
                }
            }
            board = concatenate(board, "\n");
        }
        return board;
    }

    function whosWin() public view returns (uint8) {
        for (uint8 i = 0; i < 8; i++) {
            uint8[] memory tt = tests[i];
            if (field[tt[0]] == field[tt[1]] && field[tt[1]] == field[tt[2]]) {
                return field[tt[0]];
            }
        }
        return 0;
    }

    function currState() public view returns (string memory, string memory) {
        string memory promt;
        uint8 win = whosWin();
        if (win == 1) {
            promt = "X has won! (player1)";
        } else if (win == 2) {
            promt = "O has won! (player2)";
        } else {
            promt = "Nobody has won yet!";
        }
        return (promt, lookBoard());
    }
}
