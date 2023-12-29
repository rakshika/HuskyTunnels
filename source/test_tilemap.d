import tilemap: DrawableTileMap;
import camera: Camera;

import unit_threaded;
import bindbc.sdl;

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
    
    int window_width = 960;
    int window_height = 640;
    SDL_Window* window= SDL_CreateWindow("D SDL Painting",
                                SDL_WINDOWPOS_UNDEFINED,
                                SDL_WINDOWPOS_UNDEFINED,
                                window_width,
                                window_height, 
                                SDL_WINDOW_SHOWN | 
                                SDL_WINDOW_RESIZABLE);

    //this.mySurface = Surface(window_width, window_height);
    SDL_Renderer* renderer = SDL_CreateRenderer(window,-1,SDL_RENDERER_ACCELERATED);
    Camera camera = Camera(960, 640,2048,2048);
    // Load our tiles from an image
    DrawableTileMap dt = DrawableTileMap(renderer, "assests/DTEAM.bmp");
    auto src = dt.mWorldTexture;
    dt.Render(renderer, camera);
    auto dst = dt.mWorldTexture;
    assert (src == dst);

    // Clean up resources
    destroy(dt);
    destroy(camera);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}