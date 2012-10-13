$(document).ready ->
  $(".events .span12").append('<center><br/><br/><img src="/img/ajax-loader.gif" /></center>')
  showPosition = (position) ->
    if position.coords.latitude?
      $.getJSON "/places.json?lat=#{position.coords.latitude}&lon=#{position.coords.longitude}", (data) ->
        $(".events .span12").html("")
        for event in data
          eventhtml = "
            <div class='well'>
              <h4>#{event.name}</h4>
              <p>#{event.description}</p>
              <div class='tags'>"
          for tag in event.tags 
            eventhtml += "<span class='badge badge-info'>#{tag}</span> "
          eventhtml += "</div><div class='distance'>#{event.distance.toFixed(1)}m</div></div>"
          $(".events .span12").append(eventhtml)
  defaultPosition = () ->
    alert "We could not find your location, so we will show you cool places in Tulsa."
    showPosition 
      coords:
        longitude: "-95.99278"
        latitude: "36.1539"
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition showPosition, defaultPosition
    
      
