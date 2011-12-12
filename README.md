This is a proof-of-concept demo, which shows communication between multiple clients via WebSockets.

## Install

Clone this repository to your local machine

    git clone http://github.com/muxcmux/wscomm
  
You will need a few extra gems, so go ahead and install them in one fell swoop:

    gem install sinatra coffee-script em-websocket uuidtools yajl colorize
  
There are more dependancies, but they should be automatically resolved once you have installed all the above gems. If it barks about something not being installed, you can always `gem install` it

## Server

Start the websocket server via `ruby server.rb`. It binds to `0.0.0.0` on port `8080` by default. You can change that if you open the _server.rb_ file and look at the bottom.

## Client

Although the client can be any static html/js file, this particular one is running on sinatra and is written in coffeescript. Start it by typing `ruby client.rb` and it will listen for connections on port 4567.

## Test the demo

You need to change the `ws_config` hash to meet your network configuration - `ip` should point to the websocket server ip address on you local network, so that other devices (your phone) are able to connect to it. Fire up a Google Chrome and point to http://localhost:4567 on you desktop/laptop. This creates a screen, where all connected phone clients will show up. Next, open the same URL on your phone to create a controller connection. All connected phones should be shown on all connected screens. Keep in mind that an iPhone will fire the `deviceorientation` event 50 times per second, which results in 50 requests to the server each second. Connecting a few phones to several screens can quickly screw your computer up :)

## TODO

  * Design a better way to handle method invocation between client and server
  * Handle errors when connection is lost/interrupted
  * Refactor ruby code, so Phones and Desktop screens go in separate classes
  * Use box2djs or similar library to create more interactivity
  * More features?