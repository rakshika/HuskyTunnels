import unit_threaded;
import Packet: Packet;
import core.stdc.string;

// Test that the packet is sereaized correctly into a char buffer
unittest {
    Packet packet;
    packet.setPacketData(1, 0, 1, 0, 0, "Test");
    char[Packet.sizeof] buffer = packet.getPacketAsBuffer;
    assert(buffer[0] == '1');
    assert(buffer[2] == '1');
    int len;
    memmove(&len, &buffer[11], len.sizeof);
    assert(len == 4);
}