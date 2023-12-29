## To run the application over a local network
1. Start the server with the below command:   
   dub run -- server   
   \<Make a note of the server ip address\>
2. Start one or more clients and join the server using the below command:   
   dub run   
   \<Enter the server ip when prompted\>
      
User arrow keys to move the players around the tunnel.   
Type in the terminal to send messages in the group chat.   
To send a text file, at the terminal type "attachment \<path to the file\>". You will be able to send the file only to players in your close proximity. Choose the player you want to send the file to and it will be unicasted to them.

## To run the application over localhost
1. Start the server on localhost by running the below command:   
   dub run -- server localhost   
2. Start one or more clients and connect them to the server on localhost using the command:   
   dub run   
   \<Just click enter when prompted for the server ip\>
      
You can use the application the same way it can be used over a local network.

## To run the clients in standalone mode
1. Start the clients with below command:   
   dub run   
   \<Just hit enter when prompted for server ip\>
      
Since there is no server running on local host the client will start in standalone mode. This time feature like chat, fileshare and synchronized movements between the clients will not be available.
