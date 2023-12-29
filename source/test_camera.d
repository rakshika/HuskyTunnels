import camera: Camera;
import unit_threaded;

unittest {
    auto camera = new Camera(960, 640, 2048, 2048);
    assert(camera.width == 960);
    assert(camera.height == 640);
    assert(camera.worldWidth == 2048);
    assert(camera.worldHeight == 2048);

    camera.centerOn(480, 320);
    assert(camera.x == 0);
    assert(camera.y == 0);

    camera.centerOn(1568, 1688);
    assert(camera.x == 1088);
    assert(camera.y == 1368);

    camera.centerOn(-100, -100);
    assert(camera.x == 0);
    assert(camera.y == 0);

    camera.centerOn(2500, 2500);
    assert(camera.x == 1088);
    assert(camera.y == 1408);

    destroy(camera);
}