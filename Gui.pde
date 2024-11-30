class Gui {
  ControlP5 cp5;
  Gui(ControlP5 _cp5) {
    cp5 = _cp5;
    println("Gui created");
  }

  void init () {
    cp5.setColorForeground(color(255, 100));
    cp5.setColorBackground(color(255, 50));
    addButtons();
    addSliders();
  }

  void addButtons () {
    int w = 50;
    int h = 20;
    int x = width - w - 20;

    cp5.addBang("set_send_lines")
      .setPosition(x, 50)
      .setSize(w, h)
      .setCaptionLabel("Set Send Lines")
			.setTriggerEvent(Bang.RELEASE)
      .getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER)
      ;

  }

  void addSliders () {
    // add slides for small and big steps
    cp5.addSlider("small_step")
      .setPosition(20, 20)
      .setSize(100, 20)
      .setRange(1, 100)
      .setValue(1)
      .setLabel("Small Step")
      ;
    cp5.addSlider("big_step")
      .setPosition(20, 50)
      .setSize(100, 20)
      .setRange(10, 1000)
      .setValue(10)
      .setLabel("Big Step")
      ;

  }
}