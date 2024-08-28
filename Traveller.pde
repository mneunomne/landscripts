class Traveller {
  ArrayList<Line> lines; 
  
  int curLineIndex = 0;
  int currentPointIndex = 0;

  Point lastPoint;

  ArrayList<PVector> path;

  PVector curPos;

  int direction = 1;

  int curIndex = 0;

  // csv file
  Table table;

  Traveller(String path_filename) {
    // load csv file
    // Load the CSV file
    table = loadTable("data/path.csv", "header");
    // Iterate through the rows and print the values
    path = new ArrayList<PVector>();
    for (TableRow row : table.rows()) {
      String id = row.getString("id");
      int x = row.getInt("x");
      int y = row.getInt("y");
      path.add(new PVector(x, y));
    }    
    curPos = path.get(0);
  }

  PVector step () {
    curIndex += direction;
    if (curIndex >= path.size()) {
      curIndex = path.size() - 1;
      direction = -1;
    }
    if (curIndex < 0) {
      curIndex = 0;
      direction = 1;
    }
    curPos = path.get(curIndex);
    return curPos;
  }

  void display () {
    fill(255);
    ellipse(curPos.x, curPos.y, 10, 10);
  }
}