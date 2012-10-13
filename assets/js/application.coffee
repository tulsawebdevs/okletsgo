$(document).ready ->
  socket = io.connect(document.uri)
  showPosition = (position) ->
    if position.coords.latitude?
      socket.emit "load_events",
        lat: position.coords.latitude
        long: position.coords.longitude
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition showPosition
  socket.on "new_events", (data) ->
    for event in data.events
      $(".events .span4").append("
        <div class='well'>
          <div class='distance'>#{event.distance} MI</div>
          <h4>#{event.title}</h4>
          <p>#{event.description}</p>
        </div>")

