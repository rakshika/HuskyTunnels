module test_fileSharing;
import unit_threaded;
import std.stdio;
import Packet: Packet;
import std.file;
import MockClient: MockClient;


unittest {
    // Simulate sending a file
    string sentFileContent = "This is a test file content.";
    string sentFilePath = "sentFile.txt";
    std.file.write(sentFilePath, sentFileContent);


    auto mockPacket = new Packet();
    mockPacket.setPacketData(1, 2, 3, 0, 0, sentFilePath);

    MockClient mockClient = new MockClient();

    // Simulate sending the file using the mock client
    mockClient.sendFile(2, sentFilePath, *mockPacket); 

    // Ensure the content of the sent and received files is the same
    auto receivedFileContent = readText("receivedFile.txt");
    assert(sentFileContent == receivedFileContent, "File content mismatch");

    // Clean up: Delete temporary files
    std.file.remove(sentFilePath);
    std.file.remove("receivedFile.txt");
}
