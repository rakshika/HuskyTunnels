module Packet;

import std.conv;
import core.stdc.string;
import std.stdio;

/***********************************
 * Packet structure to communicate between server and client
 * Header Fields:
 * clientID: client ID of the source client.
 * sendTo: client ID of the destination client. Set to 0 if broadcast
 * action: Type of data the packet contains.
 *         1 - chat, 2- move, 3 - fileshare, 4 - setup, 5 - update
 * x, y: x, y coordinates of the clients if its a move packet.
 * message: chat message to be sent.
 *
 * Has methods to serealize and deserealize packet into a buffer.
 */
struct Packet{
    char clientID;  // playerID (number from 1 to 4 as a char) 0 - server
    char sendTo; // 0 if its a broadcast for chat; for movement it takes 0 - left, 1 - right, 2 - up, 3 - down
    char action; // 1 - chat, 2- move, 3 - fileshare, 4 - setup, 5 - update
    int x; // if move, x and y position to move to.
    int y;
    char[64] message; // chat message limited to 64 bytes. For setup:string of clients who are active.
    int msgLen; // message length to help deserialize

    // Set packet data
    void setPacketData(int id, int send, int act, int xPos, int yPos, string msg) {
        string value = id.to!string;
        clientID = value[0];
        value = send.to!string;
        sendTo = value[0];
        value = act.to!string;
        action = value[0];
        x = xPos;
        y = yPos;  
        msgLen = cast(int)msg.length;             
        message[0 .. msg.length] = msg.dup;
    }

    // Serialization
    char[Packet.sizeof] getPacketAsBuffer(){
        char[Packet.sizeof] buffer = new char[Packet.sizeof];
        // Populate the buffer with the packet data
        buffer[0] = clientID;
        buffer[1] = sendTo;
        buffer[2] = action;
        memmove(&buffer[3], &x, x.sizeof);
        memmove(&buffer[7], &y, y.sizeof);
        memmove(&buffer[11], &msgLen, msgLen.sizeof);
        memmove(&buffer[15], &message, message.sizeof);
        return buffer;
    }

    // Deserialization
    static Packet getPacketFromBuffer(char[] buffer, ulong bufferSize){
        Packet packet;
        // Populate the packet fields with data from the buffer
        packet.clientID = buffer[0];
        packet.sendTo = buffer[1];
        packet.action = buffer[2];
        memmove(&packet.x, &buffer[3], packet.x.sizeof);
        memmove(&packet.y, &buffer[7], packet.y.sizeof);
        memmove(&packet.msgLen, &buffer[11], packet.msgLen.sizeof);
        memmove(&packet.message, &buffer[15], packet.message.sizeof);
        return packet;
    }
}