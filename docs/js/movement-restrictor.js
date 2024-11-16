// movement-restrictor

AFRAME.registerComponent('movement-restrictor', {
  schema: {
    w: {type: 'number'},
    z: {type: 'number'}
  },

  init: function() {
    this.cameraEl = document.getElementById('camera')
    this.min_x = - this.data.w/2 
    this.max_x = this.data.w - this.data.w/2

    this.min_z = - this.data.z/2 
    this.max_z = this.data.z - this.data.z/2
  },

  tick: function() {
    let {x, y, z} = this.cameraEl.object3D.position
    if (x <= this.min_x) x = this.min_x
    if (x >= this.max_x) x = this.max_x
    if (z <= this.min_z) z = this.min_z
    if (z >= this.max_z) z = this.max_z
    this.cameraEl.object3D.position.set(x, y, z)
  }
})