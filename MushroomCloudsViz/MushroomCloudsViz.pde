import netP5.*;
import oscP5.*;

static float resampleY = 3.0;

volatile ArrayList<DataPoint> incoming;

OscP5 oscP5;


void setup() {
  size(1920, 1080, P3D);
  oscP5 = new OscP5(this, 57140);
  incoming = new ArrayList<DataPoint>();
  background(0);
  frameRate(60);
  noStroke();
}

void draw() {
  ArrayList<DataPoint> drawing = incoming;
  incoming = new ArrayList<DataPoint>();
    
  for(DataPoint point : drawing) {
    int x = int(point.pos.x * width);
    int y = int(floor(point.pos.y * height / resampleY) * resampleY);
    fill(point.value * 255);
    rect(x, y, 3, resampleY);
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage msg) {
  
  if(msg.addrPattern().equals("/m")) {
    DataPoint point = new DataPoint(new PVector(msg.get(0).floatValue(), msg.get(1).floatValue()), msg.get(2).floatValue());
    incoming.add(point);
  }
}
