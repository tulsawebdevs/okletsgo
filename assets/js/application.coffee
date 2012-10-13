$(document).ready ->
  showPosition = (position) ->
    if position.coords.latitude?
      $.getJSON "/places.json?lat=#{position.coords.latitude}&lon=#{position.coords.longitude}", (data) ->
        for event in data
          $(".events .span4").append("
            <div class='well'>
              <div class='distance'>#{event.distance} MI</div>
              <h4>#{event.name}</h4>
              <p>#{event.description}</p>
            </div>")
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition showPosition
    
      
