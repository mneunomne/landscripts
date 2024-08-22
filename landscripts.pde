/*
Landscripts
22.08.2024
by @mneunomne
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

/* states */
static final int IDLE               = 0;
static final int DRAW_MODE          = 1;
static final int SEND_LINES         = 2;
static final int WAIT_DRAW_NEXT     = 3;
String [] states = {
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
String [] machine_states = {
  "IDLE",
  "MOVING_TO",
  "DRAWING",
  "MOVING_TO_ENDED",
  "DRAWING_TO_ENDED"
};
int machine_state = 0;

int lastWaitTime = 0;

boolean noMachine = true;

void setup() {  
  //name of sketch
  surface.setTitle("Landscripts");
  size(800, 800);

  gui = new Gui(cp5);
  gui.init();

  machineController = new MachineController(this, noMachine);

  map = new Map("rios.kml", "barreiras.kml");
  map.calculate();

  traveller = new Traveller(map.rios);
}

void draw() {
  background(255);
  
  map.drawRios();
  
  traveller.step();
  traveller.display();
}