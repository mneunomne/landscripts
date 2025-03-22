class Map {

  ArrayList<PVector[]> simplified_latlng = new ArrayList<PVector[]>();
  ArrayList<PVector[]> rios_latlng = new ArrayList<PVector[]>();
	ArrayList<PVector[]> escritas_latlng = new ArrayList<PVector[]>();
	ArrayList<PVector[]> barreiras_latlng = new ArrayList<PVector[]>();

	ArrayList<Line> all_lines = new ArrayList<Line>();
  ArrayList<Line> simplified = new ArrayList<Line>();
  ArrayList<Line> rios = new ArrayList<Line>();
  ArrayList<Line> rios_barreiras = new ArrayList<Line>();
	ArrayList<Line> escritas = new ArrayList<Line>();

	// shapes
	ArrayList<Line> barreiras = new ArrayList<Line>();

  ArrayList<Intersection> rios_intersections = new ArrayList<Intersection>();
	ArrayList<Intersection> escritas_intersections = new ArrayList<Intersection>();
	
  // top, bottom, right, left, 
  PVector translate = new PVector(0, 0);

  float[] bounds;
  float minLat = -22.40520000; //-22.40732500;
  float maxLat = -22.32638056; //-22.32425556;
  float minLng = -43.10237778; //-43.10468333;	
  float maxLng = -43.01715833; //-43.01486111;

  Map(String rios_filename, String simplified_filename, String escritas_filename, String barreiras_filename) {
		// load rios as lines
    parseLines(rios_filename, rios_latlng);
		parseLines(escritas_filename, escritas_latlng);

		// parse shapes
		parseShapes(barreiras_filename, barreiras_latlng);

		// parse simplified
		// parseLines(simplified_filename, simplified_latlng);
    
    ArrayList<PVector[]> all_coords = new ArrayList<PVector[]>();
    all_coords.addAll(simplified_latlng);
    all_coords.addAll(rios_latlng);
		all_coords.addAll(escritas_latlng);
    // bounds = getBounds(simplified_latlng);
    // minLat = bounds[0];
    // maxLat = bounds[1];
    // minLng = bounds[2];
    // maxLng = bounds[3];
  }
	
	void parseLines (String lines_filename, ArrayList<PVector[]> lines_latlng) {
		XML lines_kml = loadXML(lines_filename);
		XML[] lines_xml = lines_kml.getChild("Document").getChild("Folder").getChildren("Placemark");
    for (XML line_xml : lines_xml) {
      String name = line_xml.getChild("name").getContent();
			//println(name);
      XML coordinates;
      coordinates = line_xml.getChild("LineString").getChild("coordinates");
      PVector[] coords = convertXmlCoords(coordinates);
      lines_latlng.add(coords);
    }
	}

	void parseShapes (String shapes_filename, ArrayList<PVector[]> shapes_latlng) {
		// Load and parse the KML file
    XML shapes_kml = loadXML(shapes_filename);
    
    // Find all LineString elements
    XML[] shapes_xml = shapes_kml.getChild("Document").getChild("Folder").getChildren("Placemark");
    for (XML shape_xml : shapes_xml) {
      XML coordinates = shape_xml.getChild("Polygon").getChild("outerBoundaryIs").getChild("LinearRing").getChild("coordinates");
      PVector[] coords = convertXmlCoords(coordinates);
      shapes_latlng.add(coords);
    }
	}

  void calculate() {
    //calculateLines(simplified_latlng, simplified);
    calculateLines(rios_latlng, rios);
		calculateLines(escritas_latlng, escritas);
		calculateLines(barreiras_latlng, barreiras);

    rios_barreiras.addAll(rios);
    rios_barreiras.addAll(barreiras);

		// add all lines to calculate intersections
    calculateIntersections(rios, rios, 10*scale, 2, 2);
		// calculateIntersections(simplified, simplified , 10*scale, 10);
		//calculateIntersections(rios, barreiras, 20*scale, 2, 2);
		calculateIntersections(escritas, escritas, 20*scale, 2, 2);
    //calculateIntersections(escritas, rios, 60*scale, 2, 2);

    all_lines.addAll(rios);
    all_lines.addAll(escritas);
    all_lines.addAll(barreiras);

	}

  void calculateShapes(ArrayList<PVector[]> shapes_latlng, ArrayList<Shape> shapes) {
    for (PVector[] coords : shapes_latlng) {
      ArrayList<PVector> points = new ArrayList<PVector>();
      for (PVector coord : coords) {
        float x = map(coord.x, minLng, maxLng, translate.x, CANVAS_WIDTH + translate.x);
        float y = map(coord.y, minLat, maxLat, CANVAS_HEIGHT + translate.y, translate.y);
        // if point is in bounds, add to points
        if (x > CANVAS_MARGIN && x < CANVAS_WIDTH - CANVAS_MARGIN && y > CANVAS_MARGIN && y < CANVAS_HEIGHT - CANVAS_MARGIN) {
          points.add(new PVector(x, y));
        }
      }
      if (points.size() > 0) {
        Shape s = new Shape(points);
        shapes.add(s);
      }
    }
  }

  void calculateLines(ArrayList<PVector[]> lines_latlng, ArrayList<Line> lines) {
    for (PVector[] coords : lines_latlng) {
      ArrayList<PVector> points = new ArrayList<PVector>();
      for (PVector coord : coords) {
        float x = map(coord.x, minLng, maxLng, translate.x, CANVAS_WIDTH + translate.x);
        float y = map(coord.y, minLat, maxLat, CANVAS_HEIGHT + translate.y, translate.y);
        if (x > CANVAS_MARGIN && x < CANVAS_WIDTH - CANVAS_MARGIN && y > CANVAS_MARGIN && y < CANVAS_HEIGHT - CANVAS_MARGIN) {
          points.add(new PVector(x, y));
        }
      }
      if (points.size() > 0) {
        Line l = new Line(points, coords);
        lines.add(l);
      }
    }
    
    // reorder rios from biggest to smallest
    Collections.sort(lines, new Comparator<Line>() {
      public int compare(Line a, Line b) {
        return b.size() - a.size();
      }
    });
    
    // set index for each line
    for (int i = 0; i < lines.size(); i++) {
      lines.get(i).setIndex(i);
    }
  }

  void drawRios() {
    // blue color
    pg.stroke(0, 0, 255);
		pg.noFill();
    for (Line rio : rios) {
      rio.display();
    }
  }

	void drawBarreiras() {
    // clay color
		pg.stroke(244, 164, 96);
		pg.fill(244, 164, 96, 100);
    for (Line barreira : barreiras) {
      barreira.display();
    }
  }

  void drawSimplified() {
    // clay color stroke rgb: 244, 164, 96
    // teal
		pg.stroke(0, 128, 128);
		//pg.fill(244, 164, 96, 100);
		pg.noFill();
    for (Line line : simplified) {
      line.display();
    }
  }

	void drawEscritas() {
		pg.stroke(255, 0, 0);
		pg.noFill();
		for (Line escrita : escritas) {
			escrita.display();
		}
	}

  void calculateIntersections(ArrayList<Line> lines1, ArrayList<Line> lines2, float minDistance, int maxConnections1, int maxConnections2) {
    // Check if we're comparing the same set of lines to itself
    boolean excludent = lines1 != lines2;
    
    for (int i = 0; i < lines1.size(); i++) {
      Line line1 = lines1.get(i);
      
      // Skip if this line already has maximum connections
      if (maxConnections1 != Integer.MAX_VALUE) {
        int connectionsCount1 = 0;
        for (Intersection intersection : line1.intersections) {
          if (lines2.contains(intersection.l2)) {
            connectionsCount1++;
          }
        }
        
        if (connectionsCount1 >= maxConnections1) continue;
      }
      
      for (int j = 0; j < lines2.size(); j++) {
        Line line2 = lines2.get(j);
        
        // Skip self
        if (line1.id == line2.id) continue;
        
        // Skip if line2 already has maximum connections
        if (maxConnections2 != Integer.MAX_VALUE) {
          int connectionsCount2 = 0;
          for (Intersection intersection : line2.intersections) {
            if (lines1.contains(intersection.l1)) {
              connectionsCount2++;
            }
          }
          
          if (connectionsCount2 >= maxConnections2) continue;
        }
        
        // Check if these lines already have an intersection
        boolean alreadyConnected = false;
        for (Intersection existingIntersection : line1.intersections) {
          if (existingIntersection.l2 == line2) {
            alreadyConnected = true;
            break;
          }
        }
        
        if (alreadyConnected) continue;
        
        // For excluding indirect connections if needed
        if (excludent) {
          // Check for indirect connections
          boolean hasIndirectConnection = false;
          
          // Check if line1 is connected to any other line that's connected to line2
          for (Intersection intersection1 : line1.intersections) {
            Line connectedLine = intersection1.l2;
            
            for (Intersection intersection2 : connectedLine.intersections) {
              if (intersection2.l2 == line2) {
                hasIndirectConnection = true;
                break;
              }
            }
            
            if (hasIndirectConnection) break;
          }
          
          if (hasIndirectConnection) continue;
        }
        
        // Find closest points between the two lines
        Point closestPoint1 = null;
        Point closestPoint2 = null;
        float closestDistance = Float.MAX_VALUE;
        
        // Iterate through all points in both lines to find closest pair
        for (int m = 0; m < line1.size(); m++) {
          Point point1 = line1.getPoint(m);
          
          for (int n = 0; n < line2.size(); n++) {
            Point point2 = line2.getPoint(n);
            
            float distance = PVector.dist(point1.pos, point2.pos);
            
            // Update closest pair if this pair is closer
            if (distance < closestDistance && distance < minDistance) {
              closestDistance = distance;
              closestPoint1 = point1;
              closestPoint2 = point2;
            }
          }
        }
        
        // Create intersection if valid points were found
        if (closestPoint1 != null && closestPoint2 != null) {
          Intersection newIntersection = new Intersection(closestPoint1, closestPoint2, line1, line2);
          
          // Add the intersection to both points and both lines
          closestPoint1.addIntersection(newIntersection);
          closestPoint2.addIntersection(newIntersection);
          line1.addIntersection(newIntersection);
          line2.addIntersection(newIntersection);
        }
      }
    }
  }

  float[] getBounds(ArrayList<PVector[]> polygons) {
    float[] bounds = new float[4];
    float minLat = 90;
    float maxLat = -90;
    float minLng = 180;
    float maxLng = -180;
    for (PVector[] coords : polygons) {
      for (PVector coord : coords) {
        if (coord.x < minLat) {
          minLat = coord.x;
        }
        if (coord.x > maxLat) {
          maxLat = coord.x;
        }
        if (coord.y < minLng) {
          minLng = coord.y;
        }
        if (coord.y > maxLng) {
          maxLng = coord.y;
        }
      }
    }
    bounds[0] = minLat;
    bounds[1] = maxLat;
    bounds[2] = minLng;
    bounds[3] = maxLng;
    return bounds;
  }

  PVector[] convertXmlCoords(XML coordinates) {
    String[] s_coordinates = coordinates.getContent().split(" ");
    PVector[] coords = new PVector[s_coordinates.length];
    for (int i = 0; i < s_coordinates.length; i++) {
      if (s_coordinates[i].split(",").length < 2) {
        continue;
      }
      float lat = Float.parseFloat(s_coordinates[i].split(",")[0]);
      float lng = Float.parseFloat(s_coordinates[i].split(",")[1]);
      PVector location = new PVector(lat, lng);
      coords[i] = location;
    }
    return coords;
  }

	ArrayList<Point> getPointsFromPos (PVector pos) {
		boolean wasFound = false;
		ArrayList<Point> points = new ArrayList<Point>();
		for (Line rio : rios) {
			for (Point point : rio.points) {
				if (point.x == pos.x && point.y == pos.y) {
					points.add(point);
					wasFound = true;
				}
			}
		}
		// all_lines
		for (Line line : all_lines) {
			for (Point point : line.points) {
				if (point.x == pos.x && point.y == pos.y) {
					points.add(point);
					wasFound = true;
				}
			}
		}
		return points;
	}

	JSONObject getLatLngFromPos (PVector pos) {
		float lat = map(pos.y, CANVAS_WIDTH, 0, minLat, maxLat);
		float lng = map(pos.x, 0, CANVAS_HEIGHT, minLng, maxLng);
		JSONObject latlng = new JSONObject();
		latlng.setFloat("lat", lat);
		latlng.setFloat("lng", lng);
		return latlng;
	}

	void display() {
		//drawSimplified();
		drawRios();
		drawEscritas();
		drawBarreiras();
	}
}