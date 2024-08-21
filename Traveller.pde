class Traveller {
  ArrayList<Line> lines; 

  PathFinder pathFinder = new PathFinder();

  // ArrayList<Intersection> intersections;
  // ArrayList<PVector> travelledPoints = new ArrayList<PVector>(); 
  
  int curLineIndex = 0;
  int currentPointIndex = 0;

  int direction = 1;

  Point lastPoint;

  ArrayList<Line> visitedLines = new ArrayList<Line>();

  Traveller(ArrayList<Line> _lines) {
    lines = _lines;
  }

  void step () {

    Line curLine = lines.get(curLineIndex);

    // add to visitedLines
    if (!visitedLines.contains(curLine)) {
      visitedLines.add(curLine);
    }

    Point curPoint = curLine.getCurPoint(); 
    curPoint.visited = true;

    if (curPoint.hasIntersection) {
      curPoint = onIntersection(curLine, curPoint);
      curLine = curPoint.parentLine;
      curLine.setCurIndex(curPoint.index);
      curLineIndex = curLine.index;
      // random direction 
      direction = random(1) > 0.5 ? 1 : -1;
    }

    if (curPoint.getIsEndPoint()) {
      println("End point reached");
      // invert direction
      direction = -1;
    } else if (curPoint.getIsStartPoint() && direction == -1) {
      println("Start point reached");
      // invert direction
      direction = 1;
    } else if (curLine.reachedEnd && !curLine.reachedStart) {
      direction = -1;
    } else if (curLine.reachedStart && !curLine.reachedEnd) {
      direction = 1;
    }

    curLine.step(direction);
  }

  Point onIntersection(Line curLine, Point curPoint) {
    println("Intersection reached");

    ArrayList <Intersection> intersections = curPoint.getIntersections();

    //ArrayList<Line> otherLines = new ArrayList<Line>();
    int maxConnectedLines = 0;
    Line otherLine = null;
    Intersection intersectionPath = null;
    for (Intersection intersection : intersections) {
      Line l = intersection.getOtherLine(curLine);
      ArrayList<Line> connectedLines = filterNotVisitedLines(l.getOtherConnectedLines(l, intersections));
      println("otherConnectedLines: " + connectedLines.size());
      // uncheck all lines
      for (Line line : lines) {
        line.setIsChecked(false);
      }
      if (otherLine == null || connectedLines.size() > maxConnectedLines) {
        maxConnectedLines = connectedLines.size();
        otherLine = l;
        intersectionPath = intersection;
      }
    }
  
    boolean changeLine = otherLine != null && otherLine != curLine;

    if (maxConnectedLines == 0) {
      changeLine = !otherLine.getIsVisited();
    }

    // change line
    if (changeLine) {
      return intersectionPath.getOtherPoint(curPoint);
    } else {
      return curPoint;
    }
  }

  void display () {
    Point curPoint = lines.get(curLineIndex).getCurPoint();
    fill(255);
    if (curPoint.getIsEndPoint()) {
      fill(0, 255, 0);
    }
    if (curPoint.getIsStartPoint()) {
      fill(0, 0, 255);
    }
    if (curPoint.hasIntersection) {
      fill(255, 0, 0);
    }
    PVector pos = curPoint.pos;
    ellipse(pos.x, pos.y, 10, 10);
  }


  ArrayList<Line> filterNotVisitedLines (ArrayList<Line> lines) {
    ArrayList<Line> notVisitedLines = new ArrayList<Line>();
    for (Line line : lines) {
      if (!line.getIsVisited()) {
        notVisitedLines.add(line);
      }
    }
    return notVisitedLines;
  }
}