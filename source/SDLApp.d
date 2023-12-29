module SDLApp;

import std.stdio;
import std.string;
import std.socket;
import std.regex;
import core.thread.osthread;
import core.stdc.stdlib;
import sprite;
import tilemap;
import player;
import camera;
import collisionmap;
import std.file;
import Packet: Packet;
import std.conv;
import std.datetime;
import std.math;
import std.algorithm;
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

/***********************************
 * The SDL setup for the client.
 * Runs the game loop on the client side.  
 * Handles the client communications and chat input.
 */
class SDLApp{
    private:
        SDL_Window* window;
        SDL_Renderer* renderer;
        bool standaloneClient;
        static bool isSDLLoaded;
        Socket mSocket;
        bool runApplication;
        Camera camera;
        DrawableTileMap dt;
        int[][] tileMap;
        int myID;
        Player[] playerList;
        Player standalonePlayer;

    public: 
        /// setup SDL and start the client.       
        this() {
            this.runApplication = true;
            standaloneClient = false;
            InitializeSDL();
            int window_width = 960;
            int window_height = 640;
            this.window= SDL_CreateWindow("Husky Tunnels",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        window_width,
                                        window_height, 
                                        SDL_WINDOW_SHOWN | 
                                        SDL_WINDOW_RESIZABLE);

            this.renderer = SDL_CreateRenderer(window,-1,SDL_RENDERER_ACCELERATED);
            this.camera = Camera(960, 640,2048,2048);
            // Load our tiles from an image
            this.dt = DrawableTileMap(renderer, "assests/DTEAM.bmp");

            // get the collision map
            string csvData;
            try {
                csvData = readText("assests/DTeam-TunnelMap.csv");
            } catch (Exception e) {
                writeln("Error reading tilemap file: ", e.msg);
                return;
            }
            this.tileMap = parseCSV(csvData);

            // Start the Client
            startClient();
        }

        /// At the module level, when we terminate, we make sure to 
        /// terminate SDL, which is initialized at the start of the application.
        ~this(){
            // Quit the SDL Application 
            this.runApplication = false;
            SDL_DestroyWindow(window);
            SDL_Quit();
            writeln("Ending application--good bye!\n");
        }
    
        static synchronized void InitializeSDL() {
            // Load the SDL libraries from bindbc-sdl
            // on the appropriate operating system
            SDLSupport ret;
            version(Windows){
                writeln("Searching for SDL on Windows");
                ret = loadSDL("SDL2.dll");
            }
            version(OSX){
                writeln("Searching for SDL on Mac");
                ret = loadSDL();
            }
            version(linux){ 
                writeln("Searching for SDL on Linux");
                ret = loadSDL();
            }

            // Error if SDL cannot be loaded
            if(ret != sdlSupport){
                writeln("error loading SDL library");
                
                foreach( info; loader.errors){
                    writeln(info.error,':', info.message);
                }
            }
            if(ret == SDLSupport.noLibrary){
                writeln("error no library found");    
            }
            if(ret == SDLSupport.badLibrary){
                writeln("Eror badLibrary, missing symbols, perhaps an older or very new version of SDL is causing the problem?");
            }

            // Initialize SDL
            if(SDL_Init(SDL_INIT_EVERYTHING) !=0){
                writeln("SDL_Init: ", fromStringz(SDL_GetError()));
            }
        }

        /// Main application game loop which listens to keyboard inputs.
        void mainApplicationLoop() {
            int tileSize = 64;
            // How 'zoomed' in are we
            int zoomFactor =3;

            // Main application loop
            while(this.runApplication){
                SDL_Event event;
                while(SDL_PollEvent(&event)){
                    // Handle each specific event
                    if(event.type == SDL_QUIT){
                        this.runApplication = false;
                        exit(0);
                        // break;
                    }
                }

                // Get Keyboard input
                const ubyte* keyboard = SDL_GetKeyboardState(null);

                if(!standaloneClient) {
                    camera.centerOn(playerList[myID-1].GetX(), playerList[myID-1].GetY());
                } else {
                    camera.centerOn(standalonePlayer.GetX(), standalonePlayer.GetY());
                }
            
                // Check for movement
                if(keyboard[SDL_SCANCODE_LEFT]){
                    if(!standaloneClient) {
                        playerList[myID-1].MoveLeft(tileMap, tileSize);
                        int x = playerList[myID-1].GetX();
                        int y = playerList[myID-1].GetY();
                        Packet packet;
                        packet.setPacketData(this.myID, 0, 2, x, y, "");
                        mSocket.send(packet.getPacketAsBuffer);
                    } else {
                        standalonePlayer.MoveLeft(tileMap, tileSize);
                    }
                }
                if(keyboard[SDL_SCANCODE_RIGHT]){
                    if(!standaloneClient) {
                        playerList[myID-1].MoveRight(tileMap, tileSize);
                        int x = playerList[myID-1].GetX();
                        int y = playerList[myID-1].GetY();
                        Packet packet;
                        packet.setPacketData(this.myID, 1, 2, x, y, "");
                        mSocket.send(packet.getPacketAsBuffer);
                    } else {
                        standalonePlayer.MoveRight(tileMap, tileSize);
                    }
                }
                if(keyboard[SDL_SCANCODE_UP]){
                    if(!standaloneClient) {
                        playerList[myID-1].MoveUp(tileMap, tileSize);
                        int x = playerList[myID-1].GetX();
                        int y = playerList[myID-1].GetY();
                        Packet packet;
                        packet.setPacketData(this.myID, 2, 2, x, y, "");
                        mSocket.send(packet.getPacketAsBuffer);
                    } else {
                        standalonePlayer.MoveUp(tileMap, tileSize);
                    }
                }
                if(keyboard[SDL_SCANCODE_DOWN]){
                    if(!standaloneClient) {
                        playerList[myID-1].MoveDown(tileMap, tileSize);
                        int x = playerList[myID-1].GetX();
                        int y = playerList[myID-1].GetY();
                        Packet packet;
                        packet.setPacketData(this.myID, 3, 2, x, y, "");
                        mSocket.send(packet.getPacketAsBuffer);
                    } else {
                        standalonePlayer.MoveDown(tileMap, tileSize);
                    }
                }

                SDL_SetRenderDrawColor(renderer,0,0,0,SDL_ALPHA_TRANSPARENT);
                SDL_RenderClear(renderer);

                dt.Render(renderer,camera);
                // Draw our sprite
                if(!standaloneClient) {
                    foreach(p; playerList) {
                        p.Render(renderer,camera);
                    }
                } else {
                    standalonePlayer.Render(renderer,camera);
                }

                SDL_Delay(125);

                // Finally show what we've drawn
                SDL_RenderPresent(renderer);
            }
            SDL_DestroyWindow(window);
        }

        /// Listens to packets sent by the server.
        void receiveDataFromServer(){
            while(this.runApplication){
                char[80] buffer;     
                auto fromServer = buffer[0 .. mSocket.receive(buffer)];

                if(fromServer.length > 0){
                    Packet formattedPacket;
                    formattedPacket = Packet.getPacketFromBuffer(fromServer,Packet.sizeof);

                    // check what kind of packet is received.
                    // action: 1 - chat, 2- move, 3 - fileshare, 4 - setup, 5 - update
                    char act = formattedPacket.action;
                    switch (act) {
                        case '1' :  // chat logic
                                    char from = formattedPacket.clientID;
                                    auto len = formattedPacket.msgLen;
                                    writeln("(From Player ", from, ")>", formattedPacket.message[0 .. len]);
                                    break;
                        case '2' :  // move logic
                                    int clientToMove = (formattedPacket.clientID) - '0';
                                    if(clientToMove != myID) {
                                        int x = formattedPacket.x;
                                        int y = formattedPacket.y;
                                        char angle = formattedPacket.sendTo;
                                        playerList[clientToMove - 1].setLoc(x, y, angle);
                                    }
                                    break;
                        case '3' :  // file share logic
                                    char from = formattedPacket.clientID;
                                        char target = formattedPacket.sendTo;
                                        int toInt = target - '0'; 
                                        if(myID == toInt){
                                            auto timestamp = Clock.currTime().toISOExtString().replace(":", "-").replace("T", "_");
                                            auto filename = "receivedFile_" ~ timestamp ~ ".txt";
                                            receiveFile(filename,formattedPacket.message[0 .. formattedPacket.msgLen]);
                                            writeln("(Receive file from Player ", from, " file name )>", filename);
                                        }
                                    break;
                        case '4' :  // update player status when client leaves.
                                    int left = (formattedPacket.sendTo) - '0';
                                    if (left == 1) {
                                        int id = (formattedPacket.clientID) - '0'; // player that left
                                        playerList[id - 1].isAlive = false;
                                    }
                                    break;
                        case '5' :  // new players have joined the game. 
                                    // Create their avatar and their location will come as a new move packet.
                                    int id = (formattedPacket.clientID) - '0';
                                    if(id != myID) {
                                        addPlayer(id);
                                    }
                                    break;
                        default :   break;

                    }
                }
            }
        }

        void receiveFile(string filename, char[] filecontent) {
            std.file.write(filename, filecontent);
        }

        /// Send structured packets to the server.
        void sendToServer() {
            while (this.runApplication) {
                write(">");
                string userInput = readln().strip();
                if (userInput.length > 0) {
                    Packet pack;
                    
                    // check if user is trying to share a attachment
                    if (userInput.startsWith("attachment")) {
                        auto closePairs = getClosePlayerIDs();
                        if (closePairs.length == 0) {
                            writeln("No players are close. Cannot send the file.");
                        } else {
                            writeln("Close players:");
                            foreach (playerID; closePairs) {
                                writeln("Player ", playerID);
                            }
                            int targetPlayerID = getUserChoice(closePairs);
                            try {
                                auto filepath = userInput.split(" ")[1];
                                sendFile(targetPlayerID, filepath);
                            } catch (Throwable e) {
                                writeln("Error reading file: ", e.msg);
                            }
                        }
                    } else {
                        // otherwise sent a chat message
                        pack.setPacketData(this.myID, 0, 1, 0, 0, userInput);
                        mSocket.send(pack.getPacketAsBuffer);
                    }
                }
            }
        }

        void sendFile(int targetPlayerID, string filepath){
            Packet pack;
            try{
                auto fileContent = readText(filepath);
                pack.setPacketData(this.myID, targetPlayerID, 3, 0, 0, fileContent);
                mSocket.send(pack.getPacketAsBuffer);
                writeln("File sent to Player ", targetPlayerID);
            } catch (Throwable e){
                writeln("error reading file: ", e.msg);
            }
        }

        /**
         * Create the player for this client and the other
         * active players already in the game.
        */
        void createPlayer(int id, char[] active) {
            for(int i = 1; i <= id; i++) {
                Player p = Player(renderer, "assests/characters.bmp", i);
                // convert char array to int array
                int[] act;
                foreach(c;active) {
                    if(c != ' ') {
                        act ~= c - '0';
                    }
                }
                if(!canFind(act, i)) {
                    p.isAlive = false;
                }
                playerList ~= p;
            }
        }

        /// When a new client joins existing game, add the new player
        void addPlayer(int id) {
            foreach(player; playerList) {
                if(!standaloneClient) {
                    int x = player.GetX();
                    int y = player.GetY();
                    Packet packet;
                    packet.setPacketData(player.id, 1, 2, x, y, "");
                    mSocket.send(packet.getPacketAsBuffer);
                }
            }
            playerList ~= Player(renderer, "assests/characters.bmp", id);
            
        }

        /// Get the user's choice for fileshare
        int getUserChoice(int[] closePairs) {
            while (true) {
                writeln("Enter the ID of the player you want to send the file to:");
                string userInputStr = readln().strip();

                int userInput = to!int(userInputStr);
                foreach(pair;closePairs){
                    if( pair == userInput){
                        return userInput;
                    }
                }
                writeln("Invalid choice. Please enter a valid player ID.");
            }
        }
        
        /// Makes the socket connection to the server.
        void startClient() {
            string server_ip = get_server_ip();
            ushort port = 50001;
	        writeln("Starting client...attempt to create socket");
            writeln("Attempt to connect to server ip: ", server_ip);

            mSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
            try {
                mSocket.connect(new InternetAddress(server_ip, port));
                writeln("Client connected to server");
                char[80] buffer;
                auto fromServer = buffer[0 .. mSocket.receive(buffer)];
                
                Packet formattedPacket;
                formattedPacket = Packet.getPacketFromBuffer(fromServer,Packet.sizeof);

                // get the player number and create the player and start the game. 
                // (create all the previous players as well). Their locations will come in a new move packet.
                writeln("received setup info from server");
                this.myID = (formattedPacket.clientID) - '0';
                auto len = formattedPacket.msgLen;
                char[] active = formattedPacket.message[0 .. len];
                createPlayer(myID, active);

                //RUN
                writeln("Preparing to run client");
                writeln("(me)",mSocket.localAddress(),"<---->",mSocket.remoteAddress(),"(server)");
                
                // Spin up the new thread that will just take in data from the server
                new Thread({
                    receiveDataFromServer();
                }).start();

                new Thread({
                    sendToServer();
                }).start();
            } catch (Exception e) {
                // if client is unable to connect to the server, start it in standalone mode.
                standaloneClient = true;
                standalonePlayer = Player(renderer, "assests/characters.bmp", 1);
                writeln("Running Client in standalone mode...");
            }
        }

        string get_server_ip(){
            // gather server info to connect
            writeln("Please enter server ip:");
            writeln("If you wish to connect to localhost just hit enter");
            string server_ip;
            server_ip = readln();
            // Remove the newline character at the end
            if (!server_ip.empty) {
                server_ip = server_ip[0 .. $ - 1]; // Slicing off the newline character
                if (is_valid_ip(server_ip)){
                    return server_ip;
                }
                writeln("Invalid ip address: ", server_ip);
            }
            writeln("Using defualt ip: localhost");
            return "localhost"; //default localhost if emtpy input
        }

        private bool is_valid_ip(string ip){
            // regex for IPv4
            auto regex_ipv4 = regex(`^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$`);

            // check if ip address matches
            return !matchFirst(ip, regex_ipv4).empty;
        }

        /// Finds the players in close proximity to this client.
        int[] getClosePlayerIDs() {
            int[] closePlayerIds;
            Player currentPlayer = playerList[myID - 1];
            foreach (player; playerList) {
                if (player.id != currentPlayer.id && player.isAlive == true) {
                    if (isClose(currentPlayer, player)) {
                        closePlayerIds ~= player.id;
                    }
                }
            }
            return closePlayerIds;
        }

        private bool isClose(Player currentPlayer, Player otherPlayer) {
            auto dx = currentPlayer.GetX() - otherPlayer.GetX();
            auto dy = currentPlayer.GetY() - otherPlayer.GetY();
            auto distance = sqrt(cast(float)(dx * dx + dy * dy));

            return distance <= 50;
        }

}