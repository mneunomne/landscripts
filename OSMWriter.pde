
class OSMWriter {
  ArrayList<Line> lines;
  
  OSMWriter(ArrayList<Line> _lines) {
    this.lines = _lines;
  }
  
  void export(String filename, float minLat, float minLon, float maxLat, float maxLon) {
    XML osm = new XML("osm");
    osm.setString("version", "0.6");
    osm.setString("generator", "Custom KML to OSM Converter");
    
    // Add bounds element
    XML bounds = osm.addChild("bounds");
    bounds.setFloat("minlat", minLat);
    bounds.setFloat("minlon", minLon);
    bounds.setFloat("maxlat", maxLat);
    bounds.setFloat("maxlon", maxLon);
    
    long nodeId = 1;
    long wayId = 1;
    
    HashMap<PVector, Long> nodeMap = new HashMap<>();
    
    for (Line line : lines) {
      for (Point point : line.points) {
        PVector coord = new PVector(point.lng, point.lat);
				PVector pos = new PVector(point.x, point.y);
        boolean isWithinBounds = coord.x >= minLon && coord.x <= maxLon && coord.y >= minLat && coord.y <= maxLat;
        if (!isWithinBounds) {
          continue;
        }
        if (!nodeMap.containsKey(pos)) {
          long id = nodeId++;
          XML node = osm.addChild("node");
          node.setLong("id", id);
          node.setFloat("lon", coord.x);
          node.setFloat("lat", coord.y);
          node.setInt("x", point.x);
          node.setInt("y", point.y);
          nodeMap.put(pos, id);
        }
        // if point is an intersection, add the latlng of the intersection
        if (point.hasIntersection) {
          for (Intersection intersection : point.intersections) {
            coord = new PVector(intersection.lng, intersection.lat);
						pos = new PVector(intersection.x, intersection.y);
            if (!nodeMap.containsKey(pos)) {
              long id = nodeId++;
              XML node = osm.addChild("node");
              node.setLong("id", id);
              node.setFloat("lon", coord.x);
              node.setFloat("lat", coord.y);
              node.setInt("x", intersection.x);
              node.setInt("y", intersection.y);
              // add interssection tag
              XML tag = node.addChild("tag");
              tag.setString("k", "intersection");
              nodeMap.put(pos, id);
            } else {
              XML node = osm.getChildren("node")[nodeMap.get(pos).intValue() - 1];
              // check if the node already has the intersection tag
              boolean hasIntersectionTag = false;
              for (XML child : node.getChildren("tag")) {
                if (child.getString("k").equals("intersection")) {
                  hasIntersectionTag = true;
                  break;
                }
              }
              if (!hasIntersectionTag) {
                // add interssection tag
                XML tag = node.addChild("tag");
                tag.setString("k", "intersection");
              }
            }
          }
        }
      }
    }
    
    for (Line line : lines) {
      XML way = osm.addChild("way");
      way.setLong("id", wayId++);
      for (Point point : line.points) {
        PVector coord = new PVector(point.lng, point.lat);
				PVector pos = new PVector(point.x, point.y);
        boolean isWithinBounds = coord.x >= minLon && coord.x <= maxLon && coord.y >= minLat && coord.y <= maxLat;
        if (!isWithinBounds) {
          continue;
        }
        long id = nodeMap.get(pos);
        XML nd = way.addChild("nd");
        nd.setString("ref", Long.toString(id));
        if (point.hasIntersection) {
          for (Intersection intersection : point.intersections) {
            coord = new PVector(intersection.lng, intersection.lat);
						pos = new PVector(intersection.x, intersection.y);
            id = nodeMap.get(pos);
            nd = way.addChild("nd");
            nd.setString("ref", Long.toString(id));
          }
        }
      }
    }
    
    saveXML(osm, filename);
  }
}