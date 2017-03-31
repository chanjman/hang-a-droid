hangParts = ['.pole', '.level-beam', '.cross-beam', '.down-beam', '.head', '.lant', '.rant', '.body', '.arm', '.leg']
movesCheck = 10
modal = document.getElementById('game-over-modal')

$(document).ready ->
  changeDroidOpacity()
  hideShowSubmitButton()
  guessTheLetter()
  disableEnterOnForms()
  closeModal()

# Make droid transparent if on new game
changeDroidOpacity = ->
  if window.location.href.match(/new/)
    $.each hangParts, (key, value) ->
      $(value).css(opacity: '0.2')
  return

# Hide or show submit button depending on user input
hideShowSubmitButton = ->

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

# Parse and return ajax data as a hash
parseGuessData = (data) ->
  hangData = JSON.parse(data)

  moves = hangData['remaining_moves']
  guessed = hangData['guessed_letters']
  win = hangData['win']
  lost = hangData['lost']
  secret = hangData['secret_word']

  return {
    moves: moves,
    guessed: guessed,
    win: win,
    lost: lost,
    secret: secret
  }

# Place and highlight the letter if guess ok
placeLetter = (guessed, moves) ->

  i = $('.letter').length - 1
  while i >= 0
    $('.letter span').eq(i).html(guessed[i])
    i--

  if movesCheck == moves
    $('.letter span:not(:empty)').parent().effect 'highlight', color: '#2ecc71'
  return

# Set droid opacity to 1 and highlight droid part
hangTheDroid = (remaining_moves) ->
  altMoves = 9 - remaining_moves

  if altMoves >= 0
    $(hangParts[altMoves]).css(opacity: '1').addClass 'glower'
    $('.remaining_moves span').effect 'highlight', color: '#8e44ad'
  movesCheck--
  return

# Update remaining moves
checkMoves = (remaining_moves) ->

  # Update remaining moves
  $('.remaining_moves span').text(remaining_moves)
  $('.remaining_moves span').css(color: 'rgb(149, 46, 46)') if remaining_moves < 4

  # Call hangTheDroid if remaining_moves changed
  return hangTheDroid(remaining_moves) if movesCheck > remaining_moves

# Open game over modal
openModal = (msg) ->

  # Open the modal
  modal.style.display = 'block'
  $('.modal-header h2').text(msg)
  return

# To do if game over
gameOverRoutine = (state, secret) ->
  winMsg = 'You guessed it!!'
  lostMsg = 'You didn\'t guess it'

  # What to do with win
  if state['win']
    $('.letter').addClass('glow')
    setTimeout (->
      openModal(winMsg)
      return
    ), 2000

  # What to do with lost
  if state['lost']
    $('.body').addClass('hanger')
    setTimeout (->
      openModal(lostMsg)
      return
    ), 2000

  # What to do with win or lost
  if state['win'] || state['lost']
    $('.alphabet__letter').addClass('alphabet__letter--used')
    i = $('.letter').length - 1
    while i >= 0
      $('.letter span').eq(i).html(secret[i])
      i--

guessTheLetter = ->
  # Choose letter of alphabet
  $('.alphabet__letter span').click ->

    # Set clicked letter as a var to be sent for a check
    letter = $(this).text()

    # Add a class to clicked letter
    $(this).parent().addClass('alphabet__letter--used')

    # Send clicked letter for a check
    $.ajax '/guess',
      type: 'POST'
      data: { guess: letter}
      success: (data) ->
        hangData = parseGuessData(data)

        placeLetter(hangData['guessed'], hangData['moves'])

        checkMoves(hangData['moves'])

        if hangData['win']
          return gameOverRoutine({win: true}, hangData['secret'])
        else if hangData['lost']
          return gameOverRoutine({lost: true}, hangData['secret'])

# Disable enter submit on forms
disableEnterOnForms = ->
  $(document).on 'keyup keypress', 'form input[type="text"]', (e) ->
    if e.keyCode == 13 || e.keycode == 169
      e.preventDefault()
      return false
    return

# Close game over modal on click
closeModal = ->
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
