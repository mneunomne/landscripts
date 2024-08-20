class Shape {
  
  ArrayList<PVector> coords;

  Shape(ArrayList<PVector> _coords) {
    this.coords = coords;
  }

  void display () {
    beginShape();
    for (PVector coord : coords) {
      vertex(coord.x, coord.y);
    }
    endShape();
  }
}