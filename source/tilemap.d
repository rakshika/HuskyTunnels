module tilemap;
import std.stdio;
import std.string;

// Load the SDL2 library
import bindbc.sdl;
import camera;

/// DrawableTilemap is responsible for drawing 
/// the actual tiles for the tilemap data structure
struct DrawableTileMap{
    SDL_Texture* mWorldTexture;

    this(SDL_Renderer* renderer, string worldFilePath){
        // Load the world image
        writeln(worldFilePath);
        SDL_Surface* worldSurface = SDL_LoadBMP(worldFilePath.ptr);
        mWorldTexture = SDL_CreateTextureFromSurface(renderer, worldSurface);
       
        
        SDL_FreeSurface(worldSurface);
    }

    void Render(SDL_Renderer* renderer,Camera camera){
    SDL_Rect srcRect;
    srcRect.x = camera.x;  // Starting X position on the texture
    srcRect.y = camera.y;  // Starting Y position on the texture
    srcRect.w = 960; // Width of the texture area to use
    srcRect.h = 640; // Height of the texture area to use

    SDL_Rect dstRect;
    dstRect.x = 0;  // X position on the renderer
    dstRect.y = 0;  // Y position on the renderer
    dstRect.w = 960; // Width of the renderer area
    dstRect.h = 640; // Height of the renderer area

    SDL_RenderCopy(renderer, mWorldTexture, &srcRect, &dstRect);
}
}


