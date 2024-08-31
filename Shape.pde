class Shape {
  ArrayList<PVector> coords;
  
	Shape(ArrayList<PVector> _coords) {
    this.coords = _coords;
  }
  
	void display () {
    pg.beginShape();
    for (PVector coord : coords) {
      pg.vertex(coord.x, coord.y);
    }
    pg.endShape();
  }
}