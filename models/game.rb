require_relative 'dictionary.rb'
require_relative 'dict_graph.rb'
require_relative 'players.rb'
require_relative 'saveload.rb'

# Big brother for the game
class Game
  attr_reader :secret_word, :player, :id, :used_letters, :guessed_letters, :remaining_moves

  def initialize(args)
    @secret_word = args[:secret_word] || Dictionary.new.word
    @guessed_letters = args[:guessed_letters] || Array.new(secret_word.size) { '_' }
    @used_letters = args[:used_letters] || []
    @remaining_moves = args[:remaining_moves] || 10
    @player = args[:player] || Player.new
    @id = args[:id] || random_id
  end

  def guessed_so_far(letter)
    idx = (0...secret_word.length).find_all { |i| secret_word.join[i, 1] == letter }
    idx.each { |i| guessed_letters[i] = letter }
  end

  def good_guess(letter)
    used_letters << letter
    (secret_word.include?letter) ? guessed_so_far(letter) : @remaining_moves -= 1
    game_over?
  end

  def game_over?
    win? || lost?
  end

  def win?
    secret_word == guessed_letters
  end

  def lost?
    @remaining_moves.zero?
  end

  def random_id
    (rand(26) + 97).chr + (rand(899) + 100).to_s + (rand(26) + 65).chr
  end

  def to_save
    {
      id: id,
      player: player,
      secret_word: secret_word,
      guessed_letters: guessed_letters,
      used_letters: used_letters,
      remaining_moves: remaining_moves
    }
  end
end
