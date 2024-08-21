// read kml
import processing.svg.*;
import java.util.Collections;
import java.util.Comparator;

Traveller traveller;

Map map; 

void setup() {  
  //name of sketch
  surface.setTitle("Landscripts");
  size(800, 800);

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