/*
*  ......Landscripts......
*  .....by @mneunomne.....
*  ..........2024.........
*/ 

/* imports */
import controlP5.*;
import processing.serial.*;
import processing.svg.*;
import java.util.Collections;
import java.util.Comparator;

/* class objects */
Traveller traveller;
Map map; 
Gui gui;
ControlP5 cp5;

MachineController machineController;

/* constants */
static final int WAITTIME_DEFAULT   = 2000;
static final int MICRODELAY_DEFAULT = 200;
static final int CANVAS_MARGIN      = 0;

/* states */
static final int IDLE               = 0;
static final int DRAW_MODE          = 1;
static final int SEND_LINES         = 2;
static final int WAIT_DRAW_NEXT     = 3;
String[] states = {
  "IDLE",
  "DRAW_MODE",
  "SEND_LINES",
  "WAIT_DRAW_NEXT"
};
int state = 0; 

static final int MACHINE_IDLE       = 0;
static final int MOVING_TO          = 1;
static final int DRAWING            = 2;
static final int MOVING_TO_ENDED    = 3;
static final int DRAWING_TO_ENDED   = 4;
String[] machine_states = {
  "IDLE",
  "MOVING_TO",
  "DRAWING",
  "MOVING_TO_ENDED",
  "DRAWING_TO_ENDED"
};
int machine_state = 0;

int lastWaitTime = 0;

boolean noMachine = false;

void setup() {  
  //name of sketch
  surface.setTitle("Landscripts");
  size(800, 800);
  
  cp5 = new ControlP5(this);
  gui = new Gui(cp5);
  gui.init();
  
  machineController = new MachineController(this, noMachine);
  
  map = new Map("rios.kml", "barreiras.kml");
  map.calculate();
  
  traveller = new Traveller(map.rios);

}

void draw() {
  background(200);
  
  map.drawRios();
  
  traveller.display();

  machineController.update();
  machineController.display();
}

void sendDrawLine() {
  PVector nextPos = traveller.step();
  int x = int(nextPos.x);
  int y = int(nextPos.y);
  boolean valid = machineController.sendLine(x, y);
  if (!valid) {
    sendDrawLine();
  }
  //machineController.moveTo(x, y); // move to the first point of the first line
}

void goToLine () {
  Line l = map.rios.get(0);
  Point p = l.getPoint(0);
  machineController.moveTo(p.x, p.y);
}

void keyPressed() {
  // move machine WASD
  if (key == 'w') {
    machineController.move(0, -1); // up
    machineController.currentPos.y -= 1;
  }
  if (key == 's') {
    machineController.move(0, 1); // down
    machineController.currentPos.y += 1;
  }
  if (key == 'a') {
    machineController.move(1, 0); // left
    machineController.currentPos.x -= 1;
  }
  if (key == 'd') {
    machineController.move( - 1, 0); // right
    machineController.currentPos.x += 1;
  }
  
  // with uppercase - bigger movement
  if (machine_state != MOVING_TO) {
    if (key == 'W') {
      machineController.move(0, -10); // up
      machineController.currentPos.y -= 10;
    }
    if (key == 'S') {
      machineController.move(0, 10); // down
      machineController.currentPos.y += 10;
    }
    if (key == 'A') {
      machineController.move(10, 0); // left
      machineController.currentPos.x -= 10;
    }
    if (key == 'D') {
      machineController.move( - 10, 0); // right
      machineController.currentPos.x += 10;
    }
  }
}