class Map {

  ArrayList<PVector[]> simplified_latlng = new ArrayList<PVector[]>();
  ArrayList<PVector[]> rios_latlng = new ArrayList<PVector[]>();
	ArrayList<PVector[]> escritas_latlng = new ArrayList<PVector[]>();
	ArrayList<PVector[]> barreiras_latlng = new ArrayList<PVector[]>();

	ArrayList<Line> all_lines = new ArrayList<Line>();
  ArrayList<Line> simplified = new ArrayList<Line>();
  ArrayList<Line> rios = new ArrayList<Line>();
	ArrayList<Line> escritas = new ArrayList<Line>();

	// shapes
	ArrayList<Shape> barreiras = new ArrayList<Shape>();

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
		parseLines(simplified_filename, simplified_latlng);
    
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
    calculateLines(simplified_latlng, simplified);
    calculateLines(rios_latlng, rios);
		calculateLines(escritas_latlng, escritas);
		calculateShapes(barreiras_latlng, barreiras);
		//
		all_lines.addAll(simplified);
		all_lines.addAll(escritas);
		// add all lines to calculate intersections
    calculateIntersections(rios, rios, 10*scale, 9999);
		calculateIntersections(simplified, simplified , 10*scale, 10);
		calculateIntersections(escritas, escritas, 30*scale, 1);
		calculateIntersections(escritas, simplified, 100*scale, 1);
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
    for (Shape barreira : barreiras) {
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

  void calculateIntersections(ArrayList<Line> lines1, ArrayList<Line> lines2, float _minDistance, int maxConnections) {
		boolean excludent = lines1 != lines2;
    for (int i = 0; i < lines1.size(); i++) {
      Line line1 = lines1.get(i);
      Line line2;
			float minDistance = _minDistance;
      for (int j = 0; j < lines2.size(); j++) {
        line2 = lines2.get(j);
				if (line1.id == line2.id) continue;
        Intersection closestIntersection = null;
        for (int m = 0; m < line1.size(); m++) {
          Point point1 = line1.getPoint(m);
          Point point2 = null;
          for (int k = 0; k < line2.size() - 1; k++) {
            point2 = line2.getPoint(k);
            float distance = PVector.dist(point1.pos, point2.pos);
            if (distance < minDistance) {
              minDistance = distance;
              closestIntersection = new Intersection(point1, point2, line1, line2);
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
					
					// get connections that l1 with lines from lines2
					int connections = 0;
					for (Intersection intersection : l1.intersections) {
						for (Line line : lines2) {
							if (intersection.l2 == line) {
								connections++;
							}
						}
					}
					if (connections >= maxConnections) {
						//hasIntersection = true;
					}

          if (!hasIntersection) {
						for (Intersection intersection : l2.intersections) {
							if (l2 == intersection.l1 && l1 == intersection.l2) {
								hasIntersection = true;
								break;
							}
						}
					}
					if (!hasIntersection && excludent) {
						// check if current line already has intersection with any lines from lines2
						for (Intersection intersection : l1.intersections) {
							// find if any of the intersection.l2 can be found in lines2
							for (Line line : lines2) {
								if (intersection.l2 == line) {
									hasIntersection = true;
									break;
								} else {
									// also check for the intersecrtions of the intersection.l2, if they are connected to any lines2
									for (Intersection intersection2 : intersection.l2.intersections) {
										if (intersection2.l2 == line) {
											hasIntersection = true;
											break;
										}
									}
								}
							} 
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
		// all_lines
		for (Line line : all_lines) {
			for (Point point : line.points) {
				if (point.x == pos.x && point.y == pos.y) {
					points.add(point);
				}
			}
		}
		return points;
	}

	void display() {
		drawSimplified();
		drawRios();
		drawEscritas();
		drawBarreiras();
	}
}