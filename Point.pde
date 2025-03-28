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

  float lat;
  float lng;

  Point(int _x, int _y, int _index, boolean _endPoint, Line _parentLine, float _lat, float _lng) {
    x = _x;
    y = _y;
    lat = _lat;
    lng = _lng;
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
    if (hasIntersection && SHOW_INTERSECTIONS) {
			pg.pushStyle();
      // draw cross
      pg.stroke(255);
			if (SHOW_INTERSECTIONS) {
				for (Intersection intersection : intersections) {
					Line l1 = intersection.l1;
					Line l2 = intersection.l2;
					if (l1 == parentLine) {
						// draw from position to position
            pg.ellipse(intersection.p1.pos.x, intersection.p1.pos.y, 5, 5);
            pg.ellipse(intersection.p2.pos.x, intersection.p2.pos.y, 5, 5);
						pg.stroke(0, 255, 0);
						pg.line(intersection.p1.pos.x, intersection.p1.pos.y, intersection.p2.pos.x, intersection.p2.pos.y);
					}
				}
			}
   		pg.popStyle();
    }
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