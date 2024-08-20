class PathFinder {
  
  Line bestPath = null;
  int maxUnvisitedPoints = 0;
  ArrayList<Line> checkedLines = new ArrayList<>();

  Line findBestPath(Intersection intersection) {
    
    Line line1 = intersection.l1;
    Line line2 = intersection.l2;
    
    // Check the unvisited endpoints for line1
    int unvisitedPointsL1 = 0;
    if (!line1.reachedStart) {
      unvisitedPointsL1++;
    }
    if (!line1.reachedEnd) {
      unvisitedPointsL1++;
    }
    
    // Check the unvisited endpoints for line2
    int unvisitedPointsL2 = 0;
    if (!line2.reachedStart) {
      unvisitedPointsL2++;
    }
    if (!line2.reachedEnd) {
      unvisitedPointsL2++;
    }
    
    // Compare unvisited points to find the current best path
    if (unvisitedPointsL1 > unvisitedPointsL2 && unvisitedPointsL1 > maxUnvisitedPoints) {
      maxUnvisitedPoints = unvisitedPointsL1;
      bestPath = line1;
    } else if (unvisitedPointsL2 > unvisitedPointsL1 && unvisitedPointsL2 > maxUnvisitedPoints) {
      maxUnvisitedPoints = unvisitedPointsL2;
      bestPath = line2;
    }

    checkedLines.add(line1);
    checkedLines.add(line2);

    // Recursive exploration of intersections connected to line1
    for (Intersection line1Intersection : line1.getIntersections()) {
      if (line1Intersection != intersection && !checkedLines.contains(line1Intersection.getOtherLine(line1))) {
        findBestPath(line1Intersection);
      }
    }
    
    // Recursive exploration of intersections connected to line2
    for (Intersection line2Intersection : line2.getIntersections()) {
      if (line2Intersection != intersection && !checkedLines.contains(line2Intersection.getOtherLine(line2))) {
        findBestPath(line2Intersection);
      }
    }

    println("unvisitedPointsL1: " + unvisitedPointsL1 + "unvisitedPointsL2: " + unvisitedPointsL2);
    
    return bestPath;
  }
}
