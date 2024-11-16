
$(document).ready(function () {

  const assets = document.querySelector('a-assets'); // jquery elements
  console.log("assets", assets)
  assets.addEventListener('loaded', evt => {
    loaded = true;
  })

  var started = false;
  var video = document.querySelector("video")
  
  window.addEventListener("mousedown", function () {
    if (started) return;
    started = true;
    video.play()
  })
}) 
