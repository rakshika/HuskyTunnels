
import std.stdio;
import std.math;
import bindbc.sdl;
import player;


unittest {

    SDLSupport ret;
    version(Windows){
        ret = loadSDL("SDL2.dll");
    }
    version(OSX){
        ret = loadSDL();
    }
    version(linux){ 
        ret = loadSDL();
    }
    // Create a mock list of players as pointers
    Player*[] players = [
        new Player(null, "assests/characters.bmp", 1),
        new Player(null, "assests/characters.bmp", 2),
        new Player(null, "assests/characters.bmp", 3)
    ];

    // Set player positions (player 1 and 2 are close, player 3 is far)
    players[0].setLoc(100, 100, '0');
    players[1].setLoc(120, 100, '0');
    players[2].setLoc(500, 500, '0');

    // Assume player 1 is the current player
    Player currentPlayer = *players[0];

    // Modified function to accept Player*[] instead of Player[]
    int[] getClosePlayerIDs(Player currentPlayer, Player*[] players) {
        int[] closePlayerIds;
        foreach (player; players) {
            if (player.id != currentPlayer.id) {
                auto dx = currentPlayer.GetX() - player.GetX();
                auto dy = currentPlayer.GetY() - player.GetY();
                auto distance = sqrt(cast(float)(dx * dx + dy * dy));
                if (distance <= 50) {
                    closePlayerIds ~= player.id;
                }
            }
        }
        return closePlayerIds;
    }

    // Assert that only player 2 is identified as close
    auto closePlayers = getClosePlayerIDs(currentPlayer, players);
    assert(closePlayers.length == 1);
    assert(closePlayers[0] == 2);
}

