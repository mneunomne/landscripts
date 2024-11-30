class Line {
  
  ArrayList<Point> points = new ArrayList<Point>();
  
  ArrayList<Intersection> intersections = new ArrayList<Intersection>();
  
  int curIndex = -1;
  
  boolean checked = false;
  
  Point curPoint;
  
  int index;
  
  boolean reachedEnd = false;
  boolean reachedStart = false;
  
  boolean visited = false;

  PVector[] latlng;
	String id;

  Line(ArrayList<PVector> coords, PVector[] latlng) {
    this.latlng = latlng;
    for (int i = 0; i < coords.size(); i++) {
      PVector coord = coords.get(i);
      Point point = new Point((int)coord.x,(int)coord.y, i, i == coords.size() - 1, this, latlng[i].y, latlng[i].x);
      points.add(point);
    }
    curPoint = points.get(0);
    curIndex = 0;
		// generate id
		this.id = "line_" + (int)random(1000000);
  }
  
  Point step(int direction) {
    curIndex += direction;
    curPoint = points.get(curIndex);
    curPoint.visited = true;
    if (curIndex == points.size() - 1) {
      reachedEnd = true;
    }
    if (curIndex == 0) {
      reachedStart = true;
    }
    return curPoint;
  }
  
  void setCurIndex(int _curIndex) {
    curIndex = _curIndex;
  }
  
  void setIndex(int _index) {
    this.index = _index;
  }
  
  void display() {
		// for visited points
		pg.pushStyle();
			pg.beginShape();
			for (Point point : points) {
				if (point.visited) {
					pg.vertex(point.x, point.y);
				}
			}
			// open shape, no fill inside
			pg.strokeWeight(3);
			pg.stroke(244, 164, 96);
			pg.endShape();
		pg.popStyle();
		
		
		pg.beginShape();
			pg.strokeWeight(scale);
			for (Point point : points) {
				pg.vertex(point.x, point.y);
				if (point.hasIntersection) {  
					point.display();
				}
			}
    pg.endShape();
  }
  
  void addIntersection(Intersection intersection) {
    intersections.add(intersection);
  }  
  
  Point getPoint(int _index) {
    return points.get(_index);
  }
  
  Point getCurPoint() {
    return curPoint;
  }
  
  Intersection getIntersection(int index) {
    return intersections.get(index);
  }
  
  ArrayList<Intersection> getIntersections() {
    return intersections;
  }
  
  boolean getIsVisited() {
    return reachedEnd && reachedStart;
  }

  boolean getIsChecked() {
    return checked;
  }
  
  ArrayList<Line> getOtherConnectedLines(Line curLine, ArrayList<Intersection> curIntersections) {
    println("getOtherConnectedLines");
    // Mark the current line as checked to avoid infinite recursion
    curLine.setIsChecked(true);
    
    // Initialize the list of connected lines
    ArrayList<Line> otherConnectedLines = new ArrayList<Line>();
    
    // Iterate through all intersections to find lines connected to curLine
    for (Intersection intersection : curLine.intersections) {
      if (curIntersections.contains(intersection)) {
        continue;
      }
      Line otherLine = intersection.getOtherLine(curLine);
      
      // Filter out lines that have already been visited by the pathfinding
      // and also avoid those already checked in this recursive search
      if (otherLine != null && !otherLine.getIsChecked()) {
        otherConnectedLines.add(otherLine);
        
        // Recursively add lines connected to the otherLine
        otherConnectedLines.addAll(getOtherConnectedLines(otherLine, curIntersections));
      }
    }
    
    return otherConnectedLines;
  }
    
    
  ArrayList getOtherIntersections(Intersection curIntersection) {
    ArrayList<Intersection> otherIntersections = new ArrayList<Intersection>();
    for (Intersection intersection : intersections) {
      if(intersection != curIntersection) {
        otherIntersections.add(intersection);
      }
    }
    return otherIntersections;
  }
  
  int size() {
    return points.size();
  }
  
  void setIsChecked(boolean val) {
    checked = val;
  }
}