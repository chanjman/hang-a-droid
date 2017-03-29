# Players to play
class Player
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

# AI that plays hangman
class AI
  attr_reader :knowledge, :name
  attr_accessor :counter

  def initialize(word_size)
    @knowledge = DictionaryGraph.new.letter_occ_in_words(word_size)
    @name = 'AI'
    @counter = -1
  end

  def guess
    @counter += 1
    knowledge[counter]
  end
end
