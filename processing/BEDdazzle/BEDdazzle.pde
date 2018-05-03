import netP5.*;
import oscP5.*;
import g4p_controls.*;

OscP5 oscP5;
NetAddress netDMX;
NetAddressList netClientList;
int serverPort = 7777;
int broadcastPort = 8888;
String dmxIP = "127.0.0.1";
int dmxPort = 7777;

OPC opc;
PImage dot;

void setup()
{
  size( 640, 360 );
  frameRate( 25 );

  oscP5 = new OscP5( this, serverPort );

// remote OSC
// net = new NetAddress( dmxIP, dmxPort );

  oscP5.plug( this, "evtConnect", "/server/connect" );
  oscP5.plug( this, "evtDisconnect", "/server/disconnect" );
  oscP5.plug( this, "evtR", "/R" );
  oscP5.plug( this, "evtG", "/G" );
  oscP5.plug( this, "evtB", "/B" );

  // Load a sample image
  dot = loadImage("dot.png");

  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map an 8x8 grid of LEDs to the center of the window
  opc.ledGrid8x8(0, width/2, height/2, height / 12.0, 0, false, false);
}

void draw()
{
  background(0);

  // Draw the image, centered at the mouse location
  float dotSize = height * 0.7;
  image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
}

void oscEvent( OscMessage msg ) {
  if ( msg.isPlugged() ) {
    oscP5.send( msg, netClientList );
  } else {
    if ( msg.checkAddrPattern("/server/connect" ) ) {
      evtConnect( msg.netAddress().address() );
    } else if ( msg.checkAddrPattern("/server/disconnect" ) ) {
      evtDisconnect( msg.netAddress().address() );
    } else {
      println( "OSC: " + msg.typetag() + "->" + msg.addrPattern() );
    }
  }
}

public void evtConnect( String ip ) {
  if ( !netClientList.contains( ip, broadcastPort ) ) {
    netClientList.add( ip, broadcastPort );
  }

  // send control states to client

  println( "client " + ip + "connected" );
}

public void evtDisconnect( String ip ) {
  if ( !netClientList.contains( ip, broadcastPort ) ) {
    netClientList.remove( ip, broadcastPort );
  }

  println( "client " + ip + "disconnected " );
}

public void evtR( float v ) {
  println( "evtR: " + v );
}

public void evtG( float v ) {
  println( "evtG: " + v );
}

public void evtB( float v ) {
  println( "evtB: " + v );
}
