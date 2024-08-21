class Point {
  int x, y;
  PVector pos;
  boolean visited = false;
  boolean endPoint = false;
  boolean startPoint = false;
  boolean hasIntersection = false;
  int index;
  ArrayList<Intersection> intersections = new ArrayList<Intersection>();

  Line parentLine;

  Point(int _x, int _y, int _index, boolean _endPoint, Line _parentLine) {
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
    this.parentLine = _parentLine;
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

  // get Intersection with where the other line is not visited OR has most unvisited Lines connected
  Intersection getBestIntersection(Line currentLine) {
    Intersection bestIntersection = null;
    int maxUnvisitedPoints = 0;
    for (Intersection intersection : intersections) {
      Line line1 = intersection.l1;
      Line line2 = intersection.l2;
      int unvisitedPointsL1 = 0;
      if (!line1.reachedStart) {
        unvisitedPointsL1++;
      }
      if (!line1.reachedEnd) {
        unvisitedPointsL1++;
      }
      int unvisitedPointsL2 = 0;
      if (!line2.reachedStart) {
        unvisitedPointsL2++;
      }
      if (!line2.reachedEnd) {
        unvisitedPointsL2++;
      }
      if (unvisitedPointsL1 > unvisitedPointsL2 && unvisitedPointsL1 > maxUnvisitedPoints) {
        maxUnvisitedPoints = unvisitedPointsL1;
        bestIntersection = intersection;
      } else if (unvisitedPointsL2 > unvisitedPointsL1 && unvisitedPointsL2 > maxUnvisitedPoints) {
        maxUnvisitedPoints = unvisitedPointsL2;
        bestIntersection = intersection;
      }
    }
    if (bestIntersection != null) {
      return bestIntersection;
    } else {
      // return random intersection
      return getRandomIntersection();
    }
  }

  ArrayList<Intersection> getIntersections() {
    return intersections;
  }
}