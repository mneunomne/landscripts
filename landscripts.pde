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
static final int MICRODELAY_DEFAULT = 100;
static final int CANVAS_MARGIN      = 0;
static final int CANVAS_WIDTH				= 1000;
static final int CANVAS_HEIGHT      = 1000;
static final int IMAGE_RESOLUTION   = 5000;
static final int CSV_RESOLUTION		  = 1000;

static final boolean EXPORT_SVG     = false;
static final boolean EXPORT_OMS     = false;
static final boolean SAVE_FRAME     = false;
static final boolean NO_MACHINE 		= false;
static final boolean NO_INTERFACE 	= true;
static final boolean DEBUG 					= false;

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
int saveFrameCount = 0;

PImage bg;
PGraphics pg;

float scale = CANVAS_WIDTH / 800;

float img_scale = IMAGE_RESOLUTION / 800;

float csv_scale = CSV_RESOLUTION / 800;

PVector translatePos = new PVector(0, 0);

String[] pathFiles = {"data/paths/simplified.csv", "data/paths/rios.csv"};

void setup() {  
  //name of sketch
  surface.setTitle("Landscripts");
  size(800, 800);

	pg = createGraphics(CANVAS_WIDTH, CANVAS_HEIGHT);

	bg = loadImage("data/img/high_res_full.jpg");
  
  machineController = new MachineController(this, NO_MACHINE);
  
  map = new Map("kml/rios.kml", "kml/simplified.kml", "kml/escritas.kml");
  map.calculate();
  
  traveller = new Traveller(pathFiles);

  cp5 = new ControlP5(this);
  gui = new Gui(cp5);
  gui.init();

  if (EXPORT_SVG){
    noLoop();
    // export svg 
    beginRecord(SVG, "data/rios.svg");
      background(0);
      map.drawRios();
    endRecord();
    beginRecord(SVG, "data/barreiras.svg");
      background(0);
      map.drawSimplified();
    endRecord();
  }

  if (EXPORT_OMS) {
    exportData("rios");
		exportData("rios_escritas");
		exportData("simplified");
  }
}

void draw() {
	background(0);
  machineController.update();
	pg.beginDraw();
	pg.background(0);
	//pg.image(bg, 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
	map.display();
	traveller.display();
	machineController.display();
	pg.endDraw();

	if (!NO_INTERFACE) {
	}

	// display fps
	image(pg, 0, 0, width, height);


	fill(255);
	text("fps: " + int(frameRate), 10, 10);

	if (SAVE_FRAME) {
		if (frameCount % 2 == 0) {
			// save frame using saveFrameCount as name with 4 digits
			saveFrame("data/frames/frame_" + nf(saveFrameCount, 4) + ".png");
			saveFrameCount++;
		}
	}
}

void sendDrawLine() {
  PVector nextPos = traveller.step();
	translatePos.x = nextPos.x;
	translatePos.y = nextPos.y;
  int x = int(nextPos.x);
  int y = int(nextPos.y);
  boolean valid = machineController.sendLine(x, y);
	if (!valid) {
		sendDrawLine();
	}
  //machineController.moveTo(x, y); // move to the first point of the first line
}

void goToLine () {
	println("goToLine");
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

/* GUI BUTTON EVENTS */

void set_send_lines(int val) {
  //state = SEND_LINES;
  //traveller.curLineIndex = 0;
  //traveller.currentPointIndex = 0;
  println("goToLine", val);
	if (val == 1) {
  	goToLine();
	}
}

// export data as .osm
void exportData (String type) {
  //OSMWriter osmWritter = new OSMWriter(map.all_lines); 
  //osmWritter.export("data/all_lines.osm", map.minLat, map.minLng, map.maxLat, map.maxLng);

	if (type == "rios") {
		OSMWriter osmWritter = new OSMWriter(map.rios); 
		osmWritter.export("data/osm/rios.osm", map.minLat, map.minLng, map.maxLat, map.maxLng);
	}

	if (type == "rios_escritas") {
		OSMWriter osmWritter = new OSMWriter(map.all_lines); 
		osmWritter.export("data/osm/simplified_escritas.osm", map.minLat, map.minLng, map.maxLat, map.maxLng);
	}

	if (type == "simplified") {
		OSMWriter osmWritter = new OSMWriter(map.simplified); 
		osmWritter.export("data/osm/simplified.osm", map.minLat, map.minLng, map.maxLat, map.maxLng);
	}
}