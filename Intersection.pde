class Intersection {
  Point p1;
  Point p2;
  Line l1;
  Line l2;
  PVector pos;

  Intersection(Point p1, Point p2, Line l1, Line l2) {
    this.p1 = p1;
    this.p2 = p2;
    this.l1 = l1;
    this.l2 = l2;
  }

  Line getOtherLine(Line line) {
    if (line == l1) {
      return l2;
    } else {
      return l1;
    }
  }

  Point getOtherPoint(Point point) {
    if (point == p1) {
      return p2;
    } else {
      return p1;
    }
  }
}