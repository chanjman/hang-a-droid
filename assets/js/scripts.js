const hangParts = ['.pole', '.level-beam', '.cross-beam', '.down-beam',
             '.head', '.lant', '.rant', '.body', '.arm', '.leg'];

movesCheck = null;
guessedLetters = [];

$(document).ready(function () {
  clickLetter();
  disableEnterOnForms();
  if (window.location.href.match(/new-game\?/)) {
    hideShowSubmitButton();
  }

  if (window.location.href.match(/new\??.+|load\/.+/)) {
    changeDroidOpacity();
    closeModal();
    guessTheLetter();
  }

  openMenu();
  saveGame();
});

function changeDroidOpacity() {
  for (var i = 0, len = hangParts.length; i < len; i++) {
    $(hangParts[i]).css({
      opacity: '0.2',
    });
  };
};

function parseGuessData(data) {
  var hangData = JSON.parse(data);

  return {
    moves: hangData.remaining_moves,
    guessed: hangData.guessed_letters,
    win: hangData.win,
    lost: hangData.lost,
    secret: hangData.secret_word,
    used: hangData.used_letters,
  };
};

function showLetter(ltr, idx, currLetter) {
  if (currLetter.indexOf(ltr) !== -1) {
    $('.letter span').eq(idx).html(ltr);
    setTimeout(function () {
      $('.letter--overlay').eq(idx).addClass('hidden');
    }, 0);
    guessedLetters.push(ltr);
  }
};

function placeLetter(guessed) {

  var currLetter = guessed.filter(function (ltr) {
    return (guessedLetters.indexOf(ltr) === -1 && ltr !== '');
  });

  for (var i = 0, len = guessed.length; i < len; i++) {
    showLetter(guessed[i], i, currLetter);
  };
};

function spinTheDroid(idx) {
  $(hangParts[idx]).css({
    opacity: '1',
  }).addClass('spinner');
}

function hangTheDroid(remainingMoves) {
  var altMoves = [];
  var limit = 9 - remainingMoves;
  movesCheck--;

  for (var i = 0; i <= limit; i++) {
    altMoves.push(i);
  };

  for (var i = 0, len = altMoves.length; i < len; i++) {
    spinTheDroid(altMoves[i]);
  };

  $('.remaining_moves span').effect('highlight', {
    color: '#8e44ad',
  });
}

function checkMoves(remainingMoves) {
  $('.remaining_moves span').text(remainingMoves);
  if (remainingMoves < 4) {
    $('.remaining_moves span').addClass('critical');
  }

  if (movesCheck >= remainingMoves) {
    return hangTheDroid(remainingMoves);
  }
};

function openModal(msg) {
  modal = document.getElementById('game-over-modal');

  modal.style.display = 'block';
  $('#game-over-modal .modal__header h2').text(msg);
};

function gameOverRoutine(state, secret) {
  var i, lostMsg, results, winMsg;
  winMsg = 'You saved the droid!!';
  lostMsg = 'You got him hanged...';

  if (state.win) {
    setTimeout(function () {
      $('.letter span').addClass('letters-spin');
    });

    setTimeout((function () {
      openModal(winMsg);
    }), 3000);
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
    while (i >= 0) {
      $('.letter span').eq(i).html(secret[i]);
      $('.letter--overlay').eq(i).addClass('hidden');
      i--;
    }
  }
};

function guessTheLetter(letter) {
  if (typeof letter === 'undefined') { letter = ''; }

  return $.ajax('/guess', {
    type: 'POST',
    data: {
      guess: letter,
    },
    success: function (data) {
      var hangData;
      hangData = parseGuessData(data);

      if (movesCheck == null) { movesCheck = hangData.moves; };

      placeLetter(hangData.guessed);
      checkMoves(hangData.moves);
      colorUsedLetters(hangData.used);

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

function openMenu() {
  var menuButton = document.getElementById('menu-btn');
  var menuModal = document.getElementById('menu-modal');
  var menuClose = document.getElementById('menu-close');

  menuButton.onclick = function () {
    menuModal.style.display = 'block';
  };

  menuClose.onclick = function () {
    menuModal.style.display = 'none';
  };

  $(window).click(function (event) {
    if (event.target === menuModal) {
      menuModal.style.display = 'none';
    }
  });
}

function closeModal() {
  var span, modal;
  modal = document.getElementById('game-over-modal');
  span = $('.modal__close')[0];

  span.onclick = function () {
    modal.style.display = 'none';
  };

  $(window).click(function (event) {
    if (event.target === modal) {
      modal.style.display = 'none';
    }
  });
};

function clickLetter() {
  $('.alphabet__letter span').on('click touch', function () {
    letter = $(this).text();
    setTimeout(function () {
      colorUsedLetters([letter]);
      guessTheLetter(letter);
    }, 0);
  });
};

function justColor(letter, alphabet) {
  $('.alphabet__letter span').eq(alphabet.indexOf(letter)).parent().addClass('alphabet__letter--used');
}

function colorUsedLetters(letters) {
  var alphabet = $('.alphabet__letter span').text().split('');

  for (var i = 0, len = letters.length; i < len; i++) {
    justColor(letters[i], alphabet);
  };
};

function saveGame() {
  $('#save').click(function (e) {
    e.preventDefault();

    $.ajax('/save', {
      type: 'GET',
      success: function () {
        var div = document.createElement('div');
        div.className = 'saved__tooltip';
        var h3 = document.createElement('h3');
        var text = document.createTextNode('Game saved successfuly!');
        h3.appendChild(text);
        div.appendChild(h3);
        document.getElementById('menu-modal').appendChild(div);
        setTimeout(function () {
          div.parentElement.removeChild(div);
        }, 2000);
      },
    });
  });
}
