hangParts = ['.pole', '.level-beam', '.cross-beam', '.down-beam', '.head', '.lant', '.rant', '.body', '.arm', '.leg']
movesCheck = 10
modal = document.getElementById('game-over-modal')

$ ->
  # Make droid transparent if on new game
  if window.location.href.match(/new/)
    $.each hangParts, (key, value) ->
      $(value).css(opacity: '0.2')
  return
$ ->
  # Get the name
  textInput = document.getElementById('name-form')
  timeout = null

  # Show or hide new game button if name entered
  textInput.onkeyup = (e) ->
    clearTimeout timeout
    timeout = setTimeout((->
      if $.trim($('#name-form').val())
         $('#play').fadeIn(200)
      else
        $('#play').fadeOut(200)
    ), 500)
  return

$ ->
  # Choose letter of alphabet
  $('.alphabet__letter span').click ->

    # Set clicked letter as a var to be sent for a check
    letter = $(this).text()

    # Add a class to clicked letter
    $(this).parent().addClass('alphabet__letter--used')

    $.ajax '/guess',
      type: 'POST'
      data: { guess: letter}
      success: (data) ->
        hangData = JSON.parse(data)
        hangMoves = hangData['remaining_moves']
        hangGuessed = hangData['guessed_letters']
        hangWin = hangData['win']
        hangLost = hangData['lost']
        hangSecret = hangData['secret_word']

        # Add new letter to guessed if correct guess
        i = $('.letter').length - 1
        while i >= 0
          $('.letter span').eq(i).html(hangGuessed[i])
          i--

        checkMoves(hangMoves)

        winMsg = 'You guessed it!!'
        lostMsg = 'You didn\'t guess it'

        openModal(winMsg) if hangWin
        openModal(lostMsg) if hangLost

        if hangLost || hangLost
          $('.alphabet__letter').addClass('alphabet__letter--used')
          i = $('.letter').length - 1
          while i >= 0
            $('.letter span').eq(i).html(hangSecret[i])
            i--

$ ->
  # Disable enter submit on forms
  $(document).on 'keyup keypress', 'form input[type="text"]', (e) ->
    if e.keyCode == 13 || e.keycode == 169
      e.preventDefault()
      return false
    return

checkMoves = (hangMoves) ->

  # Update remaining moves
  $('.remaining_moves span').text(hangMoves)
  $('.remaining_moves span').css(color: 'rgb(149, 46, 46)') if hangMoves < 4

  # Set opacity to 1 and hihglight gallows and the droid if remaining moves change
  if movesCheck > hangMoves
    altMoves = 9 - hangMoves
    if altMoves >= 0
      $(hangParts[altMoves]).css(opacity: '1').addClass('glower')
      $('.remaining_moves span').effect('highlight', color: '#8e44ad')
    movesCheck--
  return

openModal = (msg) ->

  # Open the modal
  modal.style.display = 'block'
  $('.modal-header h2').text(msg)
  return
$ ->
  # Get the <span> element that closes the modal
  span = document.getElementsByClassName('modal-close')[0]

  # When the user clicks on <span> (x), close the modal
  span.onclick = ->
    modal.style.display = 'none'
    return

  # When the user clicks anywhere outside of the modal, close it
  window.onclick = (event) ->
    if event.target == modal
      modal.style.display = 'none'
    return
