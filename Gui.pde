class Gui {
  ControlP5 cp5;
  Gui(ControlP5 _cp5) {
    cp5 = _cp5;
    println("Gui created");
  }

  void init () {
    cp5.setColorForeground(color(255, 150));
    cp5.setColorBackground(color(255, 55));
  }
}