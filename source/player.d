module player;

import std.stdio;
import bindbc.sdl;
import sprite;
import camera;


/// Player structure that that handles the sprite movement and render.
struct Player{
    // Load our sprite
    Sprite mSprite;
    int id;
    bool isAlive;

    this(SDL_Renderer* renderer, string filepath,int playerID){
        this.id = playerID;
        this.isAlive = true;
        mSprite = Sprite(renderer,filepath, playerID-1);
    }

    int GetX(){
        return mSprite.mXPos;
    }
    int GetY(){
        return mSprite.mYPos;
    }

    void setLoc(int x, int y, char angle){
        mSprite.mXPos = x;
        mSprite.mYPos = y;
        mSprite.mState = STATE.WALK;
        switch (angle) {
            case '0':   mSprite.angle = 180; //left
                        break;
            case '2':   mSprite.angle = 270; //up
                        break;
            case '3':   mSprite.angle = 90; //down
                        break;
            default:    mSprite.angle = 0; //right
                        break;
        }
        
    }

   void MoveUp(int[][] tileMap, int tileSize) {
    if (!isCollision(mSprite.mXPos, mSprite.mYPos - 16, tileMap, tileSize)) {
        mSprite.mYPos -= 16;
        mSprite.mState = STATE.WALK;
        mSprite.angle = 270; // Facing upwards
    }
    }

    void MoveDown(int[][] tileMap, int tileSize) {
        if (!isCollision(mSprite.mXPos, mSprite.mYPos + 16 +mSprite.mRectangle.h, tileMap, tileSize)) {
        mSprite.mYPos += 16;
        mSprite.mState = STATE.WALK;
        mSprite.angle = 90; // Facing downwards
        }
    }

    void MoveLeft(int[][] tileMap, int tileSize) {
        if (!isCollision(mSprite.mXPos-16, mSprite.mYPos+(mSprite.mRectangle.h/2), tileMap, tileSize)) {
        mSprite.mXPos -= 16;
        mSprite.mState = STATE.WALK;
        mSprite.angle = 180; // Facing left
        }
    }

    void MoveRight(int[][] tileMap, int tileSize) {
        if (!isCollision(mSprite.mXPos+16+mSprite.mRectangle.w, mSprite.mYPos+(mSprite.mRectangle.h/2), tileMap, tileSize)) {
        mSprite.mXPos += 16;
        mSprite.mState = STATE.WALK;
        mSprite.angle = 0; // Facing right
        }
    }

    bool isCollision(int x, int y, int[][] tileMap, int tileSize) {
       
        int tileX = x / tileSize; 
        int tileY = y / tileSize;
        //writeln(x, ", ", y, ", ", tileX, ", ", tileY," , ",tileMap[tileY][tileX]);
     
        if (tileY >= 0 && tileY < tileMap.length && tileX >= 0 && tileX < tileMap[tileY].length) {
            return tileMap[tileY][tileX] == -1;
        } else {
            return false; 
        }
    }

    void Render(SDL_Renderer* renderer,Camera camera){
        if(isAlive) {
            mSprite.Render(renderer,camera);
            mSprite.mState = STATE.IDLE;
        }
    }
}