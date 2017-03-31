hangParts = ['.pole', '.level-beam', '.cross-beam', '.down-beam',
             '.head', '.lant', '.rant', '.body', '.arm', '.leg'];

movesCheck = 10;

guessedLetters = [];

modal = document.getElementById('game-over-modal');

$(document).ready(function () {
  changeDroidOpacity();
  guessTheLetter();
  disableEnterOnForms();
  if (window.location.href.match(/new-game\?/)) {
    hideShowSubmitButton();
  }

  if (window.location.href.match(/new\?/)) {
    closeModal();
  }
});

function changeDroidOpacity() {
  if (window.location.href.match(/new/)) {
    $.each(hangParts, function (key, value) {
      return $(value).css({
        opacity: '0.2',
      });
    });
  }
};

function parseGuessData(data) {
  var guessed, hangData, lost, moves, secret, win;
  hangData = JSON.parse(data);
  moves = hangData.remaining_moves;
  guessed = hangData.guessed_letters;
  win = hangData.win;
  lost = hangData.lost;
  secret = hangData.secret_word;
  return {
    moves: moves,
    guessed: guessed,
    win: win,
    lost: lost,
    secret: secret,
  };
};

function placeLetter(guessed, moves) {
  var currLetter = [];

  currLetter = guessed.filter(function (ltr) {
    return (guessedLetters.indexOf(ltr) === -1 && ltr !== '');
  });

  guessed.forEach(function (ltr, idx) {
    if (currLetter.indexOf(ltr) !== -1) {
      $('.letter span').eq(idx).html(ltr).parent().effect('highlight', {
        color: '#2ecc71',
      });
      guessedLetters.push(ltr);
    }
  });
};

function hangTheDroid(remainingMoves) {
  var altMoves;
  altMoves = 9 - remainingMoves;
  if (altMoves >= 0) {
    $(hangParts[altMoves]).css({
      opacity: '1',
    }).addClass('glower');
    $('.remainingMoves span').effect('highlight', {
      color: '#8e44ad',
    });
  }

  movesCheck--;
};

function checkMoves(remainingMoves) {
  $('.remaining_moves span').text(remainingMoves);
  if (remainingMoves < 4) {
    $('.remaining_moves span').css({
      color: 'rgb(149, 46, 46)',
    });
  }

  if (movesCheck > remainingMoves) {
    return hangTheDroid(remainingMoves);
  }
};

function openModal(msg) {
  modal.style.display = 'block';
  $('.modal-header h2').text(msg);
};

function gameOverRoutine(state, secret) {
  var i, lostMsg, results, winMsg;
  winMsg = 'You guessed it!!';
  lostMsg = 'You didn\'t guess it';
  if (state.win) {
    $('.letter').addClass('glow');
    setTimeout((function () {
      openModal(winMsg);
    }), 2000);
  }

  if (state.lost) {
    $('.body').addClass('hanger');
    setTimeout((function () {
      openModal(lostMsg);
    }), 2000);
  }

  if (state.win || state.lost) {
    $('.alphabet__letter').addClass('alphabet__letter--used');
    i = $('.letter').length - 1;
    results = [];
    while (i >= 0) {
      $('.letter span').eq(i).html(secret[i]);
      results.push(i--);
    }

    return results;
  }
};

function guessTheLetter() {
  return $('.alphabet__letter span').click(function () {
    var letter;
    letter = $(this).text();
    $(this).parent().addClass('alphabet__letter--used');
    return $.ajax('/guess', {
      type: 'POST',
      data: {
        guess: letter,
      },
      success: function (data) {
        var hangData;
        hangData = parseGuessData(data);
        placeLetter(hangData.guessed, hangData.moves);
        checkMoves(hangData.moves);
        if (hangData.win) {
          return gameOverRoutine({
            win: true,
          }, hangData.secret);
        } else if (hangData.lost) {
          return gameOverRoutine({
            lost: true,
          }, hangData.secret);
        }
      },

    });
  });
};

function disableEnterOnForms() {
  return $(document).on('keyup keypress', 'form input[type="text"]', function (e) {
    if (e.keyCode === 13 || e.keycode === 169) {
      e.preventDefault();
      return false;
    }
  });
};

function hideShowSubmitButton() {
  var textInput = document.getElementById('name-form');
  var timeout = null;
  textInput.onkeyup = function (e) {
    clearTimeout(timeout);
    return timeout = setTimeout((function () {
      if ($.trim($('#name-form').val())) {
        return $('#play').fadeIn(200);
      } else {
        return $('#play').fadeOut(200);
      }
    }), 500);
  };
};

function closeModal() {
  var span;
  span = $('.modal-close')[0];
  span.onclick = function () {
    modal.style.display = 'none';
  };

  window.onclick = function (event) {
    if (event.target === modal) {
      modal.style.display = 'none';
    }
  };
};
