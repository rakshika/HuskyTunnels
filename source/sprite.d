module sprite;

// Load the SDL2 library
import bindbc.sdl;
import camera;
import std.stdio;;

/// Store state for sprites and very simple animation
enum STATE{IDLE, WALK};

/// Sprite that holds a texture and position
struct Sprite{

	static SDL_Rect[4] avatarSelections= [
		SDL_Rect(426, 132, 33, 43),
        SDL_Rect(353, 132, 36, 43), 
        SDL_Rect(460, 0, 33, 43), 
		SDL_Rect(390, 176, 35, 43)
	];

		int playerID;
        int mXPos=353;
        int mYPos=132;
		SDL_Rect mRectangle;
		SDL_Texture* mTexture;
        int mFrame = 1;

        double angle = 0;

        STATE mState;

		this(SDL_Renderer* renderer, string filepath,int playerID){
			this.playerID = playerID;
			// Load the bitmap surface
			SDL_Surface* myTestImage   = SDL_LoadBMP(filepath.ptr);
			// Create a texture from the surface
			mTexture = SDL_CreateTextureFromSurface(renderer,myTestImage);
			// Done with the bitmap surface pixels after we create the texture, we have
			// effectively updated memory to GPU texture.
			SDL_FreeSurface(myTestImage);

			// Rectangle is where we will represent the shape
			mRectangle.x = mXPos;
			mRectangle.y = mYPos;
			mRectangle.w = 36;
			mRectangle.h = 43;
		}

		void Render(SDL_Renderer* renderer,Camera camera){

			SDL_Rect selection = avatarSelections[playerID % avatarSelections.length];

			mRectangle.x = mXPos-camera.x;
			mRectangle.y = mYPos-camera.y;
           

    	    SDL_RenderCopyEx(renderer, mTexture, &selection, &mRectangle, angle, null, SDL_FLIP_NONE);

            
		}
}