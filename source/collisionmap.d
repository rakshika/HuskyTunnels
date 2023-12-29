module collisionmap;

import std.algorithm;
import std.array;
import std.conv;
import std.csv;
import std.stdio;

/// Parse the CSV data
int[][] parseCSV(string csvData) {
    int[][] tileMap;

    // Split the CSV data into lines
    auto lines = csvData.split("\n");

    // Iterate over each line
    foreach (line; lines) {
        // Split the line into tiles
        auto tiles = line.split(",");
        // Convert the string tiles to integers and add to the tileMap
        tileMap ~= tiles.map!(a => to!int(a)).array;
    }

    return tileMap;
}
