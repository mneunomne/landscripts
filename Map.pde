class Map {
  ArrayList<PVector[]> barreiras_latlng = new ArrayList<PVector[]>();
  ArrayList<PVector[]> rios_latlng = new ArrayList<PVector[]>();
	ArrayList<PVector[]> escritas_latlng = new ArrayList<PVector[]>();

  ArrayList<Line> barreiras = new ArrayList<Line>();
  ArrayList<Line> rios = new ArrayList<Line>();
	ArrayList<Line> escritas = new ArrayList<Line>();

  ArrayList<Intersection> rios_intersections = new ArrayList<Intersection>();
	ArrayList<Intersection> escritas_intersections = new ArrayList<Intersection>();
	

  // top, bottom, right, left, 
  PVector translate = new PVector(0, 0);

  float[] bounds;
  float minLat = -22.40732500;
  float maxLat = -22.32425556;
  float minLng = -43.10468333;	
  float maxLng = -43.01486111;

  Map(String rios_filename, String barreiras_filename, String escritas_filename) {
		// load rios as lines
    parseLines(rios_filename, rios_latlng);
		parseLines(escritas_filename, escritas_latlng);

		// parse barreiras
		parseShapes(barreiras_filename, barreiras_latlng);
    
    ArrayList<PVector[]> all_coords = new ArrayList<PVector[]>();
    all_coords.addAll(barreiras_latlng);
    all_coords.addAll(rios_latlng);
		all_coords.addAll(escritas_latlng);
    // bounds = getBounds(barreiras_latlng);
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
    calculateShapes(barreiras_latlng, barreiras);
    calculateLines(rios_latlng, rios);
		calculateLines(escritas_latlng, escritas);
    calculateIntersections(rios);
		calculateIntersections(escritas);
  }

  void calculateShapes(ArrayList<PVector[]> shapes_latlng, ArrayList<Line> shapes) {
    for (PVector[] coords : shapes_latlng) {
      beginShape();
      // clay color fill
      noFill();
      ArrayList<PVector> points = new ArrayList<PVector>();
      for (PVector coord : coords) {
        float x = map(coord.x, minLng, maxLng, translate.x, width + translate.x);
        float y = map(coord.y, minLat, maxLat, height + translate.y, translate.y);
        // if point is in bounds, add to points
        if (x > translate.x && x < width + translate.x && y > translate.y && y < height + translate.y) {
          points.add(new PVector(x, y));
        }
      }
      if (points.size() > 0) {
        Line l = new Line(points, coords);
        shapes.add(l);
      }
      endShape(CLOSE);
    }
  }

  void calculateLines(ArrayList<PVector[]> lines_latlng, ArrayList<Line> lines) {
    for (PVector[] coords : lines_latlng) {
			println("coords.length: " + coords.length);
      ArrayList<PVector> points = new ArrayList<PVector>();
      for (PVector coord : coords) {
        float x = map(coord.x, minLng, maxLng, translate.x, width + translate.x);
        float y = map(coord.y, minLat, maxLat, height + translate.y, translate.y);
        if (x > CANVAS_MARGIN && x < width - CANVAS_MARGIN && y > CANVAS_MARGIN && y < height - CANVAS_MARGIN) {
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
    stroke(0, 0, 255);
		noFill();
    for (Line rio : rios) {
      rio.display();
    }
  }

  void drawBarreiras() {
    // clay color stroke rgb: 244, 164, 96
    stroke(244, 164, 96);
		fill(244, 164, 96, 100);
    for (Line barreira : barreiras) {
      barreira.display();
    }
  }

	void drawEscritas() {
		stroke(255, 0, 0);
		noFill();
		for (Line escrita : escritas) {
			escrita.display();
		}
	}

  void calculateIntersections(ArrayList<Line> lines) {
    for (int i = 0; i < lines.size(); i++) {
      Line line1 = lines.get(i);
      Line line2;
      float minDistance = 2.5;
      for (int j = 0; j < lines.size(); j++) {
        if (i == j) continue;
        line2 = lines.get(j);
        Intersection closestIntersection = null;
        for (int m = 0; m < line1.size(); m++) {
          boolean hasIntersection = false;
          Point point1 = line1.getPoint(m);
          Point point2 = null;
          for (int k = 0; k < line2.size() - 1; k++) {
            point2 = line2.getPoint(k);
            float distance = PVector.dist(point1.pos, point2.pos);
            if (distance < minDistance) {
              minDistance = distance;
              closestIntersection = new Intersection(point1, point2, line1, line2);
              hasIntersection = true;
            }
          }
        }
        if (closestIntersection != null) {
          Point p1 = closestIntersection.p1;
          Point p2 = closestIntersection.p2;
          Line l1 = closestIntersection.l1;
          Line l2 = closestIntersection.l2;

          // check if line l2 already has intersection with l1
          boolean hasIntersection = false;
          for (Intersection intersection : l2.intersections) {
            if (l2 == intersection.l1 && l1 == intersection.l2) {
              hasIntersection = true;
              break;
            }
          }
          if (!hasIntersection) {
            p1.addIntersection(closestIntersection);
            p2.addIntersection(closestIntersection);
            l1.addIntersection(closestIntersection);
            l2.addIntersection(closestIntersection);
          }
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
      float lat = Float.parseFloat(s_coordinates[i].split(",")[0]);
      float lng = Float.parseFloat(s_coordinates[i].split(",")[1]);
      PVector location = new PVector(lat, lng);
      coords[i] = location;
    }
    return coords;
  }

	ArrayList<Point> getPointsFromPos (PVector pos) {
		ArrayList<Point> points = new ArrayList<Point>();
		for (Line rio : rios) {
			for (Point point : rio.points) {
				if (point.x == pos.x && point.y == pos.y) {
					points.add(point);
				}
			}
		}
		return points;
	}

	void display() {
		drawBarreiras();
		drawRios();
		drawEscritas();
	}
}