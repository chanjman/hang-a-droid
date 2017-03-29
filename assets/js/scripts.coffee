$ ->
  # New or load game click event
  $('button, input :submit').click ->
    $('body').fadeOut()

$ ->
  # Get the name
  textInput = document.getElementById('name-form')
  timeout = null

  textInput.onkeyup = (e) ->
    clearTimeout timeout
    timeout = setTimeout((->
      if $.trim($('#name-form').val())
         $('#play').fadeIn(200)
      else
        $('#play').fadeOut(200)
    ), 500)
