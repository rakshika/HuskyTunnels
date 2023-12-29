module camera;

/// Structure to set the camera frame.
struct Camera {
    int x, y;
    int width, height;
    int worldWidth, worldHeight; // New fields for world dimensions

    this(int width, int height, int worldWidth, int worldHeight) {
        this.width = width;
        this.height = height;
        this.worldWidth = worldWidth; // Set the world width
        this.worldHeight = worldHeight; // Set the world height
    }

    void centerOn(int targetX, int targetY) {
        x = targetX - width / 2;
        y = targetY - height / 2;

        // Bounds checking with world dimensions
        if (x < 0) x = 0;
        if (y < 0) y = 0;
        if (x + width > worldWidth) x = worldWidth - width;
        if (y + height > worldHeight) y = worldHeight - height;
    }
}
