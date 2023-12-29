import std.stdio;
import std.math;
import bindbc.sdl;
import sprite;
import tilemap;
import player;
import std.stdio;
import std.file;
import collisionmap;

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

    string csvData;
            try {
                csvData = readText("assests/DTeam-TunnelMap.csv");
            } catch (Exception e) {
                writeln("Error reading tilemap file: ", e.msg);
                return;
            }
    // Mocking necessary data
    SDL_Renderer* renderer = null; // Mock renderer
    Player* player = new Player(renderer, "assests/characters.bmp", 1);

    // Mock tile map with a collision at a specific location
    int[][] tileMap = parseCSV(csvData); // Initialize with appropriate collision data
    int tileSize = 64;

    // Move player to a position where collision is expected
    player.setLoc(0, 0, '0'); // Set appropriate values for collisionX and collisionY

    // Assert collision detection
    assert(player.isCollision(0, 0, tileMap, tileSize));
}
