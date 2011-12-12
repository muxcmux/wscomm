# Initialize the websocket
websocket = null

# Coverts json message to string and sends it to the server
send = (json) ->
  websocket.send JSON.stringify(json)


is_mobile = ->
  navigator.userAgent.match(/(iPhone|iPad|Android|BlackBerry|webOS)/i)


create_new_player = (id, top, left) ->
  obj = $('<div></div>').addClass('player').attr('id', id).css
    top: "#{top}px",
    left: "#{left}px"
  .appendTo($('body'))
  .fadeIn('100')

remove_player = (id) ->
  $('#' + id).fadeOut '100', ->
    $(@).remove()

remove_all_players = ->
  $('.player').fadeOut '100', ->
    $(@).remove()

create_existing_players = ->
  $.each arguments, (k, v) ->
    properties = v.split('|')
    create_new_player properties[0], properties[1], properties[2]

move_player = (id, tilt_left_right, tilt_front_back, direction) ->
  $('#' + id).css
    '-webkit-transform': "rotate(#{tilt_left_right}deg) rotate3d(1,0,0, #{tilt_front_back*-1}deg)"
    '-moz-transform': "rotate(#{tilt_left_right}deg)"
    'transform': "rotate(#{tilt_left_right}deg) rotate3d(1,0,0, #{tilt_front_back*-1}deg)"

$ ->
  
  # Which screen to show?
  if is_mobile()
    $('#mobile').show()
    $('#debug').hide()
  else
    $('#desktop').show()
    
  
  # Create communication
  if window.MozWebSocket
    Socket = MozWebSocket
  else if window.WebSocket
    Socket = WebSocket
  else
    $('#websocket-error').show()
    return false
    
  
  websocket = new Socket "ws://192.168.1.66:8080/"

  websocket.onerror = ->
    alert 'The server made a boo boo.'
  

  websocket.onclose = ->
    remove_all_players()
  

  websocket.onopen = ->
    if is_mobile()
      send
        command: 'phone_has_connected'
    else
      send
        command: 'desktop_has_connected'
  
  
  websocket.onmessage = (event) ->
    json = JSON.parse event.data
    # call command from server response
    if json.arguments
      args = ''
      $.each json.arguments, (k, v)->
        args += "'#{v}', "
      args = args.slice 0, -2
      eval "#{json.command}(#{args})"
    else
      eval json.command
    # debug
    # debug = "Invoke \"#{json.command}\""
    # debug += " with arguments #{args}" if json.arguments
    # p = $('<p></p>').html(debug)
    # $('#debug').prepend(p)
  

  if is_mobile()
    window.addEventListener 'deviceorientation', (event) ->
      tilt_left_right = event.gamma
      tilt_front_back = event.beta
      direction = event.alpha
      send
        command: 'move'
        arguments: [tilt_left_right, tilt_front_back, direction]
      $('#this_phone').css
        '-webkit-transform': "rotate(#{tilt_left_right}deg) rotate3d(1,0,0, #{tilt_front_back*-1}deg)"
        '-moz-transform': "rotate(#{tilt_left_right}deg)"
        'transform': "rotate(#{tilt_left_right}deg) rotate3d(1,0,0, #{tilt_front_back*-1}deg)"
    
  




























