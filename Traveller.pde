class Traveller {
  ArrayList<ArrayList<PVector>> paths; // Stores paths for each file
  int curPathIndex = 0;  // Current path
  int curIndex = 0;      // Current position within the path
  PVector curPos;
  int direction = 1;     // Direction of movement (1 for forward, -1 for backward)
  float threshold = 10;  // Distance threshold to switch paths
  ArrayList<Point> mapPoints; // Assume this is where all the points on the map are stored

  Traveller(String[] path_filenames) {
    paths = new ArrayList<>();
    
    for (String filename : path_filenames) {
      Table table = loadTable(filename, "header");
      ArrayList<PVector> path = new ArrayList<>();
      
      for (TableRow row : table.rows()) {
        int x = int(row.getInt("x") / csv_scale);
        int y = int(row.getInt("y") / csv_scale);
        path.add(new PVector(x, y));
      }
      
      paths.add(path);
    }
    
    curPos = paths.get(curPathIndex).get(0);
  }

  PVector step() {
    curIndex += direction;
    
    ArrayList<PVector> currentPath = paths.get(curPathIndex);
    
    if (curIndex >= currentPath.size()) {
      curIndex = currentPath.size() - 1;
      direction = -1;
    } else if (curIndex < 0) {
      curIndex = 0;
      direction = 1;
    }
    
    curPos = currentPath.get(curIndex);
    
    // Check distance to the first point of the next path
    int nextPathIndex = (curPathIndex + 1) % paths.size();
    PVector nextPathFirstPos = paths.get(nextPathIndex).get(0);
    
    if (curPos.dist(nextPathFirstPos) < threshold) {
      curPathIndex = nextPathIndex;
      curIndex = 0;
      direction = 1;
    }
    
    ArrayList<Point> curPoints = map.getPointsFromPos(curPos);
    for (Point point : curPoints) {
      point.visited = true;
    }
    
    return curPos;
  }

  void display() {
    pg.fill(255);
    pg.ellipse(curPos.x, curPos.y, 10, 10);
  }
}
