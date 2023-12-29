import unit_threaded;
import Packet: Packet;
import core.stdc.string;

// Test that the packet is desereaized correctly from a buffer
unittest {
    Packet packet;
    packet.setPacketData(1, 0, 2, 140, 230, "");
    char[Packet.sizeof] buffer = packet.getPacketAsBuffer;
    Packet formattedPacket = Packet.getPacketFromBuffer(buffer,Packet.sizeof);
    assert(formattedPacket.clientID == '1');
    assert(formattedPacket.sendTo == '0');
    assert(formattedPacket.action == '2');
    assert(formattedPacket.x == 140);
    assert(formattedPacket.y == 230);
    assert(formattedPacket.msgLen == 0);
}