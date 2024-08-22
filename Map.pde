class Map {

  XML barreiras_kml;
  XML rios_kml;


  ArrayList<PVector[]> barreiras_latlng = new ArrayList<PVector[]>();
  ArrayList<PVector[]> rios_latlng = new ArrayList<PVector[]>();

  ArrayList<Shape> barreiras = new ArrayList<Shape>();
  ArrayList<Line> rios = new ArrayList<Line>();

  ArrayList<Intersection> rios_intersections = new ArrayList<Intersection>();

  // top, bottom, right, left, 
  PVector translate = new PVector(0, 70);

  float[] bounds;
  float minLat;
  float maxLat;
  float minLng;
  float maxLng;

  Map(String lines_filename, String shapes_filename) {
    // Load and parse the KML file
    barreiras_kml = loadXML(shapes_filename);
    
    // Find all LineString elements
    XML[] barreiras_xml = barreiras_kml.getChild("Document").getChild("Folder").getChildren("Placemark");
    for (XML barreira_xml : barreiras_xml) {
      XML coordinates = barreira_xml.getChild("Polygon").getChild("outerBoundaryIs").getChild("LinearRing").getChild("coordinates");
      PVector[] coords = convertXmlCoords(coordinates);
      barreiras_latlng.add(coords);
    }
    
    rios_kml = loadXML(lines_filename);
    XML[] rios_xml = rios_kml.getChild("Document").getChild("Folder").getChildren("Placemark");
    for (XML rio_xml : rios_xml) {
      String name = rio_xml.getChild("name").getContent();
      XML coordinates;
      if (name.equals("Margem")) {
        coordinates = rio_xml.getChild("Polygon").getChild("outerBoundaryIs").getChild("LinearRing").getChild("coordinates");
        continue;
      } else {
        coordinates = rio_xml.getChild("LineString").getChild("coordinates");
      }
      PVector[] coords = convertXmlCoords(coordinates);
      rios_latlng.add(coords);
    }
    
    ArrayList<PVector[]> all_coords = new ArrayList<PVector[]>();
    all_coords.addAll(barreiras_latlng);
    all_coords.addAll(rios_latlng);
    bounds = getBounds(barreiras_latlng);
    minLat = bounds[0];
    maxLat = bounds[1];
    minLng = bounds[2];
    maxLng = bounds[3];
  }

  void calculate() {
    //calculateBarreiras();
    calculateRios();
    calculateIntersections(rios);
  }

  void calculateBarreiras() {
    for (PVector[] coords : barreiras_latlng) {
      beginShape();
      // clay color fill
      noFill();
      ArrayList<PVector> points = new ArrayList<PVector>();
      for (PVector coord : coords) {
        float x = map(coord.x, minLat, maxLat, translate.x, width + translate.x);
        float y = map(coord.y, minLng, maxLng, height + translate.y, translate.y);
        vertex(x, y);
        // if point is in bounds, add to points
        if (x > translate.x && x < width + translate.x && y > translate.y && y < height + translate.y) {
          points.add(new PVector(x, y));
        }
      }
      if (points.size() > 0) {
        Shape s = new Shape(points);
        barreiras.add(s);
      }
      stroke(244, 164, 96);
      endShape(CLOSE);
    }
  }

  void calculateRios() {
    for (PVector[] coords : rios_latlng) {
      ArrayList<PVector> points = new ArrayList<PVector>();
      for (PVector coord : coords) {
        float x = map(coord.x, minLat, maxLat, translate.x, width + translate.x);
        float y = map(coord.y, minLng, maxLng, height + translate.y, translate.y);
        if (x > CANVAS_MARGIN && x < width - CANVAS_MARGIN && y > CANVAS_MARGIN && y < height - CANVAS_MARGIN) {
          points.add(new PVector(x, y));
        }
      }
      if (points.size() > 0) {
        Line l = new Line(points);
        rios.add(l);
      }
    }
    
    // reorder rios from biggest to smallest
    Collections.sort(rios, new Comparator<Line>() {
      public int compare(Line a, Line b) {
        return b.size() - a.size();
      }
    });
    
    // set index for each line
    for (int i = 0; i < rios.size(); i++) {
      rios.get(i).setIndex(i);
    }
  }

  void drawRios() {
    for (Line rio : rios) {
      rio.display();
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
}