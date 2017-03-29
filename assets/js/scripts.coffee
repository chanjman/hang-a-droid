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

$ ->
  $('.alphabet__letter span').click ->
    letter = $(this).text()
    $(this).parent().addClass('alphabet__letter--used')

    $.ajax '/guess',
      type: 'POST'
      data: { guess: letter}
      success: (data) ->
        hang = JSON.parse(data)
        $('.remaining_moves span').text(hang['remaining_moves'])

        #console.log $('.letter span').eq(0).html()
        i = $('.letter').length - 1
        while i > 0
          $('.letter span').eq(i).html(hang['guessed_letters'][i])
          i--
