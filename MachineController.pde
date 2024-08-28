class MachineController {
  
  Serial port;  // Create object from Serial class
  int portIndex = 0;
  
  PVector currentPos = new PVector(0, 0);
  
  PVector nextPos = new PVector(0, 0);
  
  PGraphics machineCanvas;
  
  boolean noMachine = true;
  
  int microdelay = MICRODELAY_DEFAULT;
  
  MachineController(PApplet parent, boolean _noMachine) {
    // if no machine, don't connect to serial
    noMachine = _noMachine;
    machineCanvas = createGraphics(width, height);
    if (noMachine) return; 
    // Connect to Serial
    print("[MachineController] SerialList: ");
    printArray(Serial.list());
    String portName = Serial.list()[portIndex]; //change the 0 to a 1 or 2 etc. to match your port
    port = new Serial(parent, portName, 115200);
    // machine canvas 
    loadStoredPosition();
  }
  
  void update() {
    if (!noMachine) {
      listenToPort();
    }
    
    switch(machine_state) {
      case MOVING_TO:
        // if machine is moving to a point, display it
        // display();
        if (noMachine) {
          currentPos = nextPos;
          machine_state = MOVING_TO_ENDED;
        }
        break;
      case MOVING_TO_ENDED:
        // if machine has finished moving to a point, display it
        sendDrawLine();
        //display();
        break;
      case DRAWING:
        // if machine is drawing a segment, display it
        if (noMachine) {
          currentPos = nextPos;
          machine_state = DRAWING_TO_ENDED;
        }
        break;
      case DRAWING_TO_ENDED:
        sendDrawLine();
        // if machine has finished drawing a segment, display it
        
        break;
      default:
      break;
    }
  }

  void display () {
    // display current position of machine
    // draw ellipse at current position
    machineCanvas.beginDraw();
    machineCanvas.background(0, 0);
    machineCanvas.noStroke();
    machineCanvas.fill(0, 255, 0, 50);
    machineCanvas.ellipse(nextPos.x, nextPos.y, 50, 50);
    machineCanvas.stroke(255, 0, 0);
    machineCanvas.line(currentPos.x-8, currentPos.y, currentPos.x+8, currentPos.y);
    machineCanvas.line(currentPos.x, currentPos.y-8, currentPos.x, currentPos.y+8);
    machineCanvas.endDraw();

    // draw text current position // with line break
    fill(0);
    text("Current Position: " + currentPos.x + "\n" + currentPos.y, height - 40, 50);
   
    image(machineCanvas, CANVAS_MARGIN, CANVAS_MARGIN, width-(CANVAS_MARGIN*2), height-(CANVAS_MARGIN*2));
  }

  void listenToPort () {
    if (noMachine) return;
    // read from serial port
    if (port.available() > 0) {
      String inBuffer = port.readStringUntil('\n');
      if (inBuffer != null) {
        println("[MachineController] Received: " + inBuffer);
        // if message is 'e' means the movement is over
        if (inBuffer.contains("end")) {
          //String index = inBuffer.substring(3, inBuffer.length()-1);
          //int point_index = int(index);
          //println("END: " + point_index);

					println("machine_state", machine_state);

          if (machine_state == MOVING_TO) {
            machine_state = MOVING_TO_ENDED;
          } else if (machine_state == DRAWING) {
            machine_state = DRAWING_TO_ENDED;
          }

					println("machine_state", machine_state);
					
          currentPos = nextPos;
          
          if (inBuffer.contains("limit")) {
            if (inBuffer.contains("end_limit_x")) {
              println("end_limit_x");
              currentPos.x = 0;
            }
            if (inBuffer.contains("end_limit_y")) {
              println("end_limit_y");
              currentPos.y = 0;
            }
            storePosition(currentPos.x, currentPos.y);
            machine_state = MACHINE_IDLE;
          }
        }
      }
    }
  }
  
  void moveHomeX() {
    if (noMachine) return;
    machineController.move(width, 0); // up
  }
  
  void moveHomeY() {
    if (noMachine) return;
    machineController.move(0, -height); // up
  }
  
  void move(int x, int y) {
    if (noMachine) return;
    // move to a point
    sendMovement(x, y, 1, microdelay, 0);
  }
  
  void moveTo(int x, int y) {
    machine_state = MOVING_TO;
    nextPos = new PVector(x, y);
    println("MOVE TO: " + x + " " + currentPos.x + " " + y + " " + currentPos.y);
    int diff_x = int(x - currentPos.x);
    int diff_y = int(y - currentPos.y);
    // invert x 
    diff_x = -diff_x;
    // send movement data
    sendMovement(diff_x, diff_y, 1, microdelay, 0);
  }
  
  boolean sendLine(int x, int y) {
    machine_state = DRAWING;
    nextPos = new PVector(x, y);
    // println("pos: " + x + " " + currentPos.x + " " + y + " " + currentPos.y);
    int diff_x = int(x - currentPos.x);
    int diff_y = int(y - currentPos.y);
    if (diff_x == 0 && diff_y == 0) {
      return false;
    }
    // invert x 
    diff_x = -diff_x;
    // draw delay
    int delay = microdelay; //+ int(random(-100, 100));
    
    // send movement data
    sendMovement(diff_x, diff_y, 2, delay, 0);
    return true;
  }
  
  void sendMovement(int x, int y, int type, int microdelay, int point_index) {
    if (noMachine) return;
    // encode movement
    // String message = "[" + x + "," + y + "]";
    String message = "G" + type +  " X" + x + " Y" + y + " F" + microdelay +  " I" + point_index + '\n';
    port.write(message);
    println("[MachineController] Sent: " + message);
  }
  
  // store last position of machine in txt file
  void storePosition(float x, float y) {
    String[] parts = {"0 0"};
    parts[0] = str(x) + " " + str(y); 
    saveStrings("data/last_position.txt", parts);
  }
  
  void loadStoredPosition() {
    String[] lines = loadStrings("data/last_position.txt");
    String[] parts = split(lines[0], ' ');
    currentPos = new PVector(int(parts[0]), int(parts[1]));
  }
}