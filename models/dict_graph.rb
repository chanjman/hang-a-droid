require 'json'
require_relative 'dictionary.rb'

# Knowledge about the dictionary
class DictionaryGraph
  attr_reader :dictionary

  def initialize
    @dictionary = Dictionary.new
  end

  # finds words in a dictionary by given size
  def find_words_by_size(word_size)
    dictionary.possible_words.find_all { |word| word.size == word_size }
  end

  # writes to json file
  def write_to_file(to_write)
    File.open('./letter_frequency.json', 'w').write(to_write.to_json)
  end

  # finds occurence of letters in words, sorted - letter => words occuring in
  def letter_occ_in_words(word_size)
    words = find_words_by_size(word_size)
    letters = ('a'..'z').each_with_object({}) { |letter, hash| hash[letter] = 0 }
    words.each do |word|
      letters.each { |letter, freq| letters[letter] += 1 if word.include? letter }
    end
    letters.sort_by { |_key, value| value }.reverse.to_h.keys
  end
end
