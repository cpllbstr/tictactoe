import brownie


def test_tictactoe(accounts, TicTacToe):
    game = TicTacToe.deploy({"from": accounts[0]})
    game.addPlayer(accounts[1])
    game.move(0, 0, {"from": accounts[0]})
    game.move(0, 2, {"from": accounts[1]})
    game.move(1, 0, {"from": accounts[0]})
    game.move(0, 1, {"from": accounts[1]})
    game.move(2, 0, {"from": accounts[0]})
    print(game.currState()[1])
    print(game.currState()[0])
    assert game.whosWin(), 1


def test_many_accs(accounts, TicTacToe):
    game = TicTacToe.deploy({"from": accounts[0]})
    game.addPlayer(accounts[1])
    with brownie.reverts("No free slots!"):
        game.addPlayer(accounts[2])


def test_occupied(accounts, TicTacToe):
    game = TicTacToe.deploy({"from": accounts[0]})
    game.addPlayer(accounts[1])
    game.move(0, 0, {"from": accounts[0]})
    with brownie.reverts("already occupied"):
        game.move(0, 0, {"from": accounts[1]})


def test_turn(accounts, TicTacToe):
    game = TicTacToe.deploy({"from": accounts[0]})
    game.addPlayer(accounts[1])
    game.move(0, 0, {"from": accounts[0]})
    with brownie.reverts():
        game.move(0, 1, {"from": accounts[0]})
