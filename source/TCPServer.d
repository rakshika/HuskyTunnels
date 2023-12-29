module TCPServer;

import std.socket;
import std.stdio;
import std.array;
import std.conv;
import core.thread.osthread;
import Packet: Packet;

struct Client {
    int clientNum;
    Socket socket;
}
/*******************************
 * The purpose of the TCPServer is to accept multiple client connections. 
 * Every client that connects will have its own thread
 * for the server to broadcast information to each client.
 */ 
class TCPServer{

    /// The listening socket is responsible for handling new client connections.
    Socket 		mListeningSocket;
    /// Stores the clients that are currently connected to the server.
    Client[]    mClientsConnectedToServer;
    /// Stores all of the data on the server.
    /// use this to broadcast out to clients connected.
    char[80][]  mServerData;
    /// Keeps track of the last message that was broadcast out to each client.
    uint[] 		mCurrentMessageToSend;
    int         clientCount;
    
    this(bool localhost=false, ushort maxConnectionsBacklog=4) {
        this.clientCount = 0;
        writeln("Starting server...");
        writeln("Server must be started before clients may join");

        string host;
        if(localhost) {
            host = "localhost";
            writeln("Starting server on localhost");
        } else {
            host = get_local_ip();
        }
        ushort port = 50001;
        writeln("Server port: ", port);

        mListeningSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
        mListeningSocket.bind(new InternetAddress(host,port));
        // Allow 4 connections to be queued up in the 'backlog'
        mListeningSocket.listen(maxConnectionsBacklog);
    }

    /// Destructor
    ~this(){
        // Close our server listening socket
        mListeningSocket.close();
    }

    /// Call this after the server has been created to start running the server
    void run(){
        bool serverIsRunning=true;
        while(serverIsRunning){
            // The servers job now is to just accept connections
            writeln("Waiting to accept more connections");
            /// accept is a blocking call.
            auto newClientSocket = mListeningSocket.accept();
            // After a new connection is accepted, let's confirm.
            writeln("Hey, a new client joined!");
            writeln("(server)",newClientSocket.localAddress(),"<---->",newClientSocket.remoteAddress(),"(client)");
            clientCount++;
            Client client;
            client.clientNum = clientCount;
            client.socket = newClientSocket;
            mClientsConnectedToServer ~= client;

            // send setup into to new client
            // string of clients who are active
            string active;
            foreach(c; mClientsConnectedToServer) {
                active ~= to!string(c.clientNum);
                active ~= " ";
            }
            Packet pack;
            pack.setPacketData(clientCount, 0, 4, 0, 0, active); 
            writeln(pack.getPacketAsBuffer);
            newClientSocket.send(pack.getPacketAsBuffer);

            // Set the current client to have '0' total messages received.
            mCurrentMessageToSend ~= 0;

            writeln("Friends on server = ",mClientsConnectedToServer.length);

            pack.setPacketData(clientCount, 0, 5, 0, 0, "");
            broadcastPacket(pack);

            // Now we'll spawn a new thread for the client that has recently joined.
            // The server will now be running multiple threads and handling a chat here with clients.
            new Thread({
                    clientLoop(client);
                }).start();
        }
    }

    // Function to spawn from a new thread for the client.
    void clientLoop(Client client){
        Socket clientSocket = client.socket;
        writeln("\t Starting clientLoop:(me)",clientSocket.localAddress(),"<---->",clientSocket.remoteAddress(),"(client)");
        
        bool runThreadLoop = true;

        while(runThreadLoop){
            // Check if the socket isAlive
            if(!clientSocket.isAlive){
                // Then remove the socket
                runThreadLoop=false;
                break;
            }

            // Message buffer will be 80 bytes 
            char[80] buffer;
            auto got = clientSocket.receive(buffer);

            // check if client dropped.
            if(got == 0) {
                Packet pack;
                pack.setPacketData(client.clientNum, 1, 4, 0, 0, "");
                broadcastPacket(pack);
                for(auto i = 0; i < mClientsConnectedToServer.length; i++) {
                    if(mClientsConnectedToServer[i].socket == clientSocket) {
                        for(auto j = i; j < mClientsConnectedToServer.length-1; j++) {
                            mClientsConnectedToServer[j] = mClientsConnectedToServer[j+1];
                        }
                        mClientsConnectedToServer.length = mClientsConnectedToServer.length-1;
                    }  
                }
                runThreadLoop=false;
                break;
            } else {
                writeln("Received some data (bytes): ", got);
                writeln("client",clientSocket.localAddress(),">",buffer);
            }
            mServerData ~= buffer;   
            broadcastToAllClients();
        }
                        
    }

    /// The purpose of this function is to broadcast messages 
    /// to all of the clients that are currently connected.
    void broadcastToAllClients(){
        writeln("Broadcasting to :", mClientsConnectedToServer.length);
        foreach(idx,serverToClient; mClientsConnectedToServer){
            while(mCurrentMessageToSend[idx] <= mServerData.length-1){
                char[80] msg = mServerData[mCurrentMessageToSend[idx]];
                serverToClient.socket.send(msg[0 .. 80]);	
                // Important to increment the message only after sending
                // the previous message to as many clients as exist.
                mCurrentMessageToSend[idx]++;
            }
        }
    }

    // Broadcast packets to other clients
    void broadcastPacket(Packet packet) {
        char[Packet.sizeof] buffer = packet.getPacketAsBuffer();
        foreach(client; mClientsConnectedToServer) {
            client.socket.send(buffer);
        }
    }

    string get_local_ip(){
        writeln("Checking local host info...");
        try {
            // Use a well known port (i.e. google) to do this
            auto r = getAddress("8.8.8.8",53); 
            // Create a socket
            auto sockfd = new Socket(AddressFamily.INET,  SocketType.STREAM);
            // Connect to the google server
            import std.conv;
            const char[] address = r[0].toAddrString().dup;
            ushort port = to!ushort(r[0].toPortString());
            sockfd.connect(new InternetAddress(address, port));
            // Obtain local sockets name and address
            writeln(sockfd.hostName);

            string local_ip_port = sockfd.localAddress.toAddrString();
            auto ip_port = split(local_ip_port, ":");
            string local_ip = ip_port.length > 0 ? ip_port[0] : "Invalid IP and Port";
            // our current ip.
            writeln("Server ip address:     ", local_ip);

            // Close our socket
            sockfd.close();

            return local_ip;
        } catch (Exception e) {
            writeln("Failed to determine local IP address: ", e.msg);
        }
        writeln("Using defualt localhost as server ip.");
        return "localhost"; //default localhost if failed get ip   
    }
}