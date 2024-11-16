/**
 * Creates a grid of entities based on the given template
 * Place at the center of the grid you wish to create
 * Requires aframe-template-component
 */
AFRAME.registerComponent('spawn-in-circle', {
  schema: {
    radius: {type: 'number', default: 1},
    index: {type: 'number', default: 0},
    max: {type: 'number', default: 8},
  },

  init: function() {
    var el = this.el;
    var center = el.getAttribute('position');

    
    var angleRad = ((Math.PI*2) / this.data.max) * this.data.index;
    angleRad = angleRad + Math.PI*16
    var circlePoint = this.getPointOnCircle(this.data.radius, angleRad);
    var worldPoint = {x: circlePoint.x + center.x, y: center.y, z: circlePoint.y + center.z};
    el.setAttribute('position', worldPoint);
    // console.log('world point', worldPoint);

    var angleDeg = angleRad * 180 / Math.PI;
    var angleToCenter = -1 * angleDeg + 90 + 180;
    var angleRad = THREE.Math.degToRad(angleToCenter);
    el.object3D.rotation.set(0, angleRad, 0);

    el.addEventListener("sound-loaded", function () {
      console.log("sound lodedad!!!")
    })
  },

  getRandomAngleInRadians: function() {
    return Math.random()*Math.PI*2;
  },

  getPointOnCircle: function (radius, angleRad) {
    var x = Math.cos(angleRad)*radius;
    var y = Math.sin(angleRad)*radius;
    return {x: x, y: y};
  }
});