class Traveller {
  ArrayList<Line> lines; 

  PathFinder pathFinder = new PathFinder();

  // ArrayList<Intersection> intersections;
  // ArrayList<PVector> travelledPoints = new ArrayList<PVector>(); 
  
  int currentLineIndex = 0;
  int currentPointIndex = 0;

  int direction = 1;

  Point lastPoint;

  ArrayList<Line> visitedLines = new ArrayList<Line>();

  Traveller(ArrayList<Line> _lines) {
    lines = _lines;
  }

  void step () {

    Line line = lines.get(currentLineIndex);
    Point point = line.getCurPoint(); 
    point.visited = true;

    if (point.hasIntersection) {
      println("Intersection reached");
      Intersection intersection = point.getRandomIntersection();
      Line otherLine = pathFinder.findBestPath(intersection);
      if (otherLine == line) {
        println("Stay on same line");
      } else {
        Point otherPoint = intersection.getOtherPoint(point);
        //direction = pathFinder.direction;
        int otherLineIndex = otherLine.index;
        int otherPointIndex = otherPoint.index;
        currentLineIndex = otherLineIndex;
        otherLine.setCurIndex(otherPointIndex);
        point = otherPoint;
        line = otherLine;
      }
    }

    if (point.getIsEndPoint()) {
      println("End point reached");
      // invert direction
      direction = -1;
    }

    if (point.getIsStartPoint() && direction == -1) {
      println("Start point reached");
      // invert direction
      direction = 1;
    }

    line.step(direction);
  }

  void display () {
    Point point = lines.get(currentLineIndex).getCurPoint();
    fill(255);
    if (point.getIsEndPoint()) {
      fill(0, 255, 0);
    }
    if (point.getIsStartPoint()) {
      fill(0, 0, 255);
    }
    if (point.hasIntersection) {
      fill(255, 0, 0);
    }
    PVector pos = point.pos;
    ellipse(pos.x, pos.y, 10, 10);
  }
}