class Line {

  ArrayList<Point> points = new ArrayList<Point>();

  ArrayList<Intersection> intersections = new ArrayList<Intersection>();

  int curIndex = -1;

  Point curPoint;

  int index;

  boolean reachedEnd = false;
  boolean reachedStart = false;

  boolean visited = false;
  
  Line (ArrayList<PVector> coords) {
    for (int i = 0; i < coords.size(); i++) {
      PVector coord = coords.get(i);
      Point point = new Point((int)coord.x, (int)coord.y, i, i == coords.size() - 1);
      points.add(point);
    }
    curPoint = points.get(0);
    curIndex = 0;
  }

  void step(int direction) {
    curIndex += direction;
    curPoint = points.get(curIndex);
    curPoint.visited = true;
    if (curIndex == points.size() - 1) {
      reachedEnd = true;
    }
    if (curIndex == 0) {
      reachedStart = true;
    }
  }

  void setCurIndex(int _curIndex) {
    curIndex = _curIndex;
  }

  void display () {
    beginShape();
    for (Point point : points) {
      vertex(point.x, point.y);
      point.display();
    }
    // open shape, no fill inside
    stroke(0);
    noFill();
    endShape();
  }

  void addIntersection (Intersection intersection) {
    intersections.add(intersection);
  }  

  Point getPoint (int index) {
    return points.get(index);
  }

  Point getCurPoint () {
    return curPoint;
  }

  Intersection getIntersection (int index) {
    return intersections.get(index);
  }

  ArrayList<Intersection> getIntersections () {
    return intersections;
  }

  boolean getIsVisited() {
    return reachedEnd && reachedStart;
  }

  int size() {
    return points.size();
  }
}