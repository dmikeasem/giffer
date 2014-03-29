"use strict"
#App start
getStream = (callback, fail) ->
  streams = (navigator.getUserMedia || navigator.mozGetUserMedia || navigator.webkitGetUserMedia || badBrowser)
  streams.call(navigator, {video: true}, callback, fail);

gif = null
master_blob = null

giffy =
  gifOpt:
    h: window.innerWidth
    w: window.innerWidth
  canvas: null
  video: null
  image: null
  video_container: null
  progress: null
  counter: null
  controls: null
  upload: null
  output: null
  appStrings:
    nope: "That's a no go..."
  do_up: (blob) ->
    form = new FormData()
    request = new XMLHttpRequest()
    form.append "post[title]", "test"
    form.append "post[body]", "another"
    form.append "authenticity_token", AUTH_TOKEN
    form.append "post[image]", blob, "new-image.gif"
    request.open "POST", "/posts", true
    request.send form
    request.onload = (oEvent) ->
      if request.status == 200
        giffy.output.innerHTML = "Uploaded!";
      else
        giffy.output.innerHTML = "Error " + oReq.status + " occurred uploading your file.<br \/>";
  start_rec: (time)->
      ctx = giffy.canvas.getContext '2d'
      count = 0
      recInterval = setInterval ->
        ctx.drawImage giffy.video, 0, 0, giffy.gifOpt.w, giffy.gifOpt.h
        gif.addFrame ctx, {copy: true, delay: 100}
        count++
        if count%10 == 0
          giffy.counter.textContent = parseInt(giffy.counter.textContent, 10)-1
        if count == time*10
          clearInterval recInterval
          makeGif()
          return 0
      , 100
      return 0
  errorCallback: (e) ->
    console.log "Houston, we have a problem\n\t", e

document.addEventListener 'DOMContentLoaded', ->
  gif = new GIF
    workers: 2
    workerScript: '/gif/dist/gif.worker.js'
    quality: 10
    height: window.innerWidth
    width: window.innerWidth
  giffy.video = document.querySelector 'video'
  giffy.video_container = document.querySelector '.recorder'
  giffy.progress = document.querySelector '.render'
  giffy.counter = document.querySelector '.counter'
  giffy.controls = document.querySelector '.control'
  giffy.canvas = document.createElement 'canvas'
  giffy.canvas.height = giffy.gifOpt.h
  giffy.canvas.width = giffy.gifOpt.w
  giffy.gifContainer = document.getElementById 'gifs'
  giffy.video.height = giffy.gifOpt.h
  giffy.video.width = giffy.gifOpt.w
  giffy.output = document.querySelector '.result'
  giffy.image = document.querySelector '.gif'
  giffy.image.addEventListener 'click', changeFilter, false
  giffy.upload = document.getElementById 'upload'
  giffy.upload.addEventListener 'click', ->
    giffy.do_up master_blob
  navigator.webkitGetUserMedia {audio: false, video: true}, (stream) ->
      source = window.webkitURL.createObjectURL stream
      giffy.video.autoplay = true
      giffy.video.src = source
  , (err) ->
    giffy.errorCallback(err)

  giffy.video_container.addEventListener 'click', ->
    giffy.start_rec 3
    giffy.controls.style.display = 'none'
  giffy.video.pause()
  gif.on 'progress', (p) ->
    giffy.progress.value = Math.round(p * 100)
  gif.on 'finished', (blob) ->
    master_blob = blob
    giffy.image.src = URL.createObjectURL(blob)
    giffy.upload.style.display = 'inline-block'

#Functions
badBrowser = ->
  track 'streaming', 'not supported'
  alert giffy.appStrings.nope

track = (feature, setting) ->
  console.log feature, setting

makeGif = ->
  giffy.video.pause()
  gif.render()


#Filters
idx = 0;
filters = ['grayscale', 'sepia', 'blur', 'brightness', 'contrast', 'hue-rotate', 'hue-rotate2', 'hue-rotate3', 'saturate', 'invert', ''];

changeFilter = (e) ->
  el = e.target;
  el.className = 'gif';
  effect = filters[idx++ % filters.length];
  if effect
    el.classList.add effect