import unit_threaded;
import TCPServer: TCPServer;
import std.range;
import std.regex;

bool is_valid_ip(string ip){
    // regex for IPv4
    auto regex_ipv4 = regex(`^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$`);

    // check if ip address matches
    return !matchFirst(ip, regex_ipv4).empty;
}


unittest {
    TCPServer server = new TCPServer();
    assert(server.clientCount == 0);
    assert(is_valid_ip(server.get_local_ip()));
    destroy(server);
}