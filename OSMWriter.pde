
class OSMWriter {
  ArrayList<Line> rios;
  
  OSMWriter(ArrayList<Line> _rios) {
    this.rios = _rios;
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
    
    for (Line line : rios) {
      for (Point point : line.points) {
        PVector coord = new PVector(point.lat, point.lng);
        boolean isWithinBounds = coord.x >= minLat && coord.x <= maxLat && coord.y >= minLon && coord.y <= maxLon;
        if (!isWithinBounds) {
          continue;
        }
        if (!nodeMap.containsKey(coord)) {
          long id = nodeId++;
          XML node = osm.addChild("node");
          node.setLong("id", id);
          node.setFloat("lat", coord.x);
          node.setFloat("lon", coord.y);
          node.setInt("x", point.x);
          node.setInt("y", point.y);
          nodeMap.put(coord, id);
        }
        // if point is an intersection, add the latlng of the intersection
        if (point.hasIntersection) {
          for (Intersection intersection : point.intersections) {
            coord = new PVector(intersection.lat, intersection.lng);
            if (!nodeMap.containsKey(coord)) {
              long id = nodeId++;
              XML node = osm.addChild("node");
              node.setLong("id", id);
              node.setFloat("lat", coord.x);
              node.setFloat("lon", coord.y);
              node.setInt("x", intersection.x);
              node.setInt("y", intersection.y);
              // add interssection tag
              XML tag = node.addChild("tag");
              tag.setString("k", "intersection");
              nodeMap.put(coord, id);
            }
          }
        }
      }
    }
    
    for (Line line : rios) {
      XML way = osm.addChild("way");
      way.setLong("id", wayId++);
      for (Point point : line.points) {
        PVector coord = new PVector(point.lat, point.lng);
        boolean isWithinBounds = coord.x >= minLat && coord.x <= maxLat && coord.y >= minLon && coord.y <= maxLon;
        if (!isWithinBounds) {
          continue;
        }
        long id = nodeMap.get(coord);
        XML nd = way.addChild("nd");
        nd.setString("ref", Long.toString(id));
        if (point.hasIntersection) {
          for (Intersection intersection : point.intersections) {
            coord = new PVector(intersection.lat, intersection.lng);
            id = nodeMap.get(coord);
            nd = way.addChild("nd");
            nd.setString("ref", Long.toString(id));
          }
        }
      }
    }
    
    saveXML(osm, filename);
  }
}