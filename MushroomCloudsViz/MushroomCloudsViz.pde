import netP5.*;
import oscP5.*;

static float resampleY = 1.0;

volatile ArrayList<DataPoint> incoming;

OscP5 oscP5;

PGraphics fbo;


void setup() {
  size(1920, 1080, P3D);
  fbo = createGraphics(width/2, height/2, P3D);
  
  oscP5 = new OscP5(this, 57140);
  incoming = new ArrayList<DataPoint>();
  frameRate(60);
  
  fbo.beginDraw();
  fbo.background(0);
  fbo.endDraw();
}

void draw() {
  
  fbo.beginDraw();
  
  ArrayList<DataPoint> drawing = new ArrayList(incoming);
  incoming = new ArrayList<DataPoint>();
    
  for(DataPoint point : drawing) {
    int x = int(point.pos.x * fbo.width);
    int y = int(point.pos.y * fbo.height);
    // int y = int(floor(point.pos.y * height / resampleY) * resampleY);
    fbo.stroke(point.value * 255);
    // rect(x, y, 3, resampleY);
    // ellipse(x, y, resampleY, resampleY);
    fbo.point(x, y);
  }
  
  fbo.endDraw();
  
  image(fbo, 0, 0, width, height);
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage msg) {
  
  if(msg.addrPattern().equals("/m")) {
    if(msg.arguments().length % 3 != 0) {return;}
    for(int i = 0; i < msg.arguments().length / 3; i++) {
      DataPoint point = new DataPoint(new PVector(msg.get(i*3).floatValue(), msg.get(i*3+1).floatValue()), msg.get(i*3+2).floatValue());
      incoming.add(point);
    }
  }
}
