import netP5.*;
import oscP5.*;

final static float resampleY = 1.0;

ArrayList<DataPoint> incoming;

OscP5 oscP5;

PGraphics fbo;

boolean clearFlag = true;


void setup() {
  size(1920, 540, P3D);
  fbo = createGraphics(width, height, P3D);
  
  oscP5 = new OscP5(this, 57140);
  incoming = new ArrayList<DataPoint>();
  frameRate(60);
}

void draw() {
  
  fbo.beginDraw();
  
  if(clearFlag) {
    fbo.background(0);
    clearFlag = false;
  }
  
  
  ArrayList<DataPoint> drawing;
  
  synchronized(incoming) {
    drawing = new ArrayList(incoming);
    incoming = new ArrayList<DataPoint>();
  }
    
  for(DataPoint point : drawing) {
    int x = int(point.pos.x * fbo.width);
    int y = int(point.pos.y * fbo.height);
    // int y = int(floor(point.pos.y * height / resampleY) * resampleY);
    float b = point.value * 255 * 1.1;
    if(b > 255) {
      b = 255;
    }
    fbo.stroke(b);
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
    synchronized(incoming) {
      for(int i = 0; i < msg.arguments().length / 3; i++) {
        DataPoint point = new DataPoint(new PVector(msg.get(i*3).floatValue(), 1.0 - msg.get(i*3+1).floatValue()), msg.get(i*3+2).floatValue());
        incoming.add(point);
      }
    }
  } else if(msg.addrPattern().equals("/clear")) {
    clearFlag = true;
  }
}

void keyPressed() {
  if (key == 'f' || key == 'F') {
    saveFrame();
  }
}
