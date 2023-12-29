module app;

import bindbc.sdl;
import SDLApp : SDLApp;
import TCPServer: TCPServer;
import std.algorithm;

/***********************************
 * Husky Tunnels app entry point.
 * Takes command line arguments to start the 
 * application as a server. If no arguments
 * are needed to start as a client.
 * The client can be started in standalone mode.
 */
void main(string[] args) {
    // Check command line arguments to run server or client
    if((args.length > 1 ) && "server".equal(args[1])) {
        TCPServer server;
        // check if server needs to be started on localhost
        if((args.length > 2) && "localhost".equal(args[2])) {
            server = new TCPServer(localhost:true);
        } else {
            server = new TCPServer();
        }
	    server.run();
    } else {
        SDLApp myApp = new SDLApp();
        myApp.mainApplicationLoop();
    }
}
