hangParts = ['.pole', '.level-beam', '.cross-beam', '.down-beam',
             '.head', '.lant', '.rant', '.body', '.arm', '.leg'];

movesCheck = 10;

modal = document.getElementById('game-over-modal');

$(document).ready(function () {
  changeDroidOpacity();
  guessTheLetter();
  closeModal();
  hideShowSubmitButton();
  disableEnterOnForms();
});

changeDroidOpacity = function () {
  if (window.location.href.match(/new/)) {
    $.each(hangParts, function (key, value) {
      return $(value).css({
        opacity: '0.2',
      });
    });
  }
};

hideShowSubmitButton = function () {
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

parseGuessData = function (data) {
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

placeLetter = function (guessed, moves) {
  var i;
  i = $('.letter').length - 1;
  while (i >= 0) {
    $('.letter span').eq(i).html(guessed[i]);
    i--;
  }

  if (movesCheck === moves) {
    $('.letter span:not(:empty)').parent().effect('highlight', {
      color: '#2ecc71',
    });
  }
};

hangTheDroid = function (remainingMoves) {
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

checkMoves = function (remainingMoves) {
  $('.remainingMoves span').text(remainingMoves);
  if (remainingMoves < 4) {
    $('.remainingMoves span').css({
      color: 'rgb(149, 46, 46)',
    });
  }

  if (movesCheck > remainingMoves) {
    return hangTheDroid(remainingMoves);
  }
};

openModal = function (msg) {
  modal.style.display = 'block';
  $('.modal-header h2').text(msg);
};

gameOverRoutine = function (state, secret) {
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

guessTheLetter = function () {
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

disableEnterOnForms = function () {
  return $(document).on('keyup keypress', 'form input[type="text"]', function (e) {
    if (e.keyCode === 13 || e.keycode === 169) {
      e.preventDefault();
      return false;
    }
  });
};

closeModal = function () {

  var span;
  span = $('.modal-close')[0];
  span.on(click, function () {
    modal.style.display = 'none';
  });

  window.on(click, function (event) {
    if (event.target === modal) {
      modal.style.display = 'none';
    }
  });
};
