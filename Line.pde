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
  
  Line(ArrayList<PVector> coords) {
    for (int i = 0; i < coords.size(); i++) {
      PVector coord = coords.get(i);
      Point point = new Point((int)coord.x,(int)coord.y, i, i == coords.size() - 1, this);
      points.add(point);
    }
    curPoint = points.get(0);
    curIndex = 0;
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
    beginShape();
    for (Point point : points) {
      vertex(point.x, point.y);
      //point.display();
    }
    // open shape, no fill inside
    noFill();
    endShape();
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