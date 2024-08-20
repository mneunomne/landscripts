class Point {
  int x, y;
  PVector pos;
  boolean visited = false;
  boolean endPoint = false;
  boolean startPoint = false;
  boolean hasIntersection = false;
  int index;
  ArrayList<Intersection> intersections = new ArrayList<Intersection>();

  Point(int _x, int _y, int _index, boolean _endPoint) {
    x = _x;
    y = _y;
    pos = new PVector(x, y);
    index = _index;
    if (index == 0) {
      startPoint = true;
    }
    if (_endPoint) {
      endPoint = true;
    }
  }

  void display() {
    noStroke();
    fill(255);
    if (visited) {
      fill(255, 0, 0);
    }
    if (endPoint) {
      fill(0, 255, 0);
    }
    if (startPoint) {
      fill(0, 0, 255);
    }
    if (hasIntersection) {
      // draw cross
      stroke(255, 0, 0);
      line(pos.x - 5, pos.y - 5, pos.x + 5, pos.y + 5);
      line(pos.x + 5, pos.y - 5, pos.x - 5, pos.y + 5);
    }
    ellipse(pos.x, pos.y, 3, 3);
  }

  void addIntersection(Intersection intersection) {
    intersections.add(intersection);
    hasIntersection = true;
  }

  boolean getIsVisited() {
    return visited;
  }

  boolean getIsEndPoint() {
    return endPoint;
  }

  boolean getIsStartPoint() {
    return startPoint;
  }

  Intersection getRandomIntersection() {
    return intersections.get((int)random(intersections.size()));
  }

  ArrayList<Intersection> getIntersections() {
    return intersections;
  }
}