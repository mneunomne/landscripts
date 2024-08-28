class Gui {
  ControlP5 cp5;
  Gui(ControlP5 _cp5) {
    cp5 = _cp5;
    println("Gui created");
  }

  void init () {
    cp5.setColorForeground(color(0, 180));
    cp5.setColorBackground(color(0, 100));
    addButtons();
  }

  void addButtons () {
    int w = 50;
    int h = 19;
    int x = width - w - 20;

    cp5.addBang("set_idle")
      .setPosition(x, 20)
      .setSize(w, h)
      .setCaptionLabel("Set Idle")
      .getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER)
      ;

    cp5.addBang("set_draw_mode")
      .setPosition(x, 40)
      .setSize(w, h)
      .setCaptionLabel("Set Draw Mode")
      .getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER)
      ;

    cp5.addBang("set_send_lines")
      .setPosition(x, 60)
      .setSize(w, h)
      .setCaptionLabel("Set Send Lines")
			.setTriggerEvent(Bang.RELEASE)
      .getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER)
      ;

    cp5.addBang("set_wait_draw_next")
      .setPosition(x, 80)
      .setSize(w, h)
      .setCaptionLabel("Set Wait Draw Next")
      .getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER)
      ;
  }
}