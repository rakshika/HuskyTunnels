module MockClient;

import std.stdio;
import std.string;
import player;
import std.file;
import Packet: Packet;
import std.conv;
import std.datetime;
import std.math;
import std.algorithm;

/// Mock client for testing
class MockClient{

        private:
        bool standaloneClient;
        bool runApplication;
        int myID;

    public: 
     
        this() {
            this.runApplication = true;
            standaloneClient = false;
        }

        ~this(){
            this.runApplication = false;
        }
        void sendFile(int targetPlayerID, string filepath, Packet packet) {
            try {
                auto fileContent = readText(filepath);
                packet.setPacketData(packet.clientID, targetPlayerID, packet.action, 0, 0, fileContent);
                receiveFile("receivedFile.txt", packet.message[0 .. packet.msgLen]);
                std.stdio.writeln("File sent to Player ", targetPlayerID);
            } catch (Throwable e) {
                std.stdio.writeln("Error reading file: ", e.msg);
            }
        }

        void receiveFile(string filename, char[] filecontent) {
            std.file.write(filename, filecontent);
        }


        bool isClose(Player currentPlayer, Player otherPlayer) {
            auto dx = currentPlayer.GetX() - otherPlayer.GetX();
            auto dy = currentPlayer.GetY() - otherPlayer.GetY();
            auto distance = sqrt(cast(float)(dx * dx + dy * dy));

            return distance <= 50;
        }

}

