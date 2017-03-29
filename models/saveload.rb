# Saves and loads the game
class SaveLoad
  SAVEFILE = '/save.json'.freeze

  def savegame_file
    JSON.parse(File.open(SAVEFILE).read, symbolize_names: true)
  end

  def savegame_by_id(input)
    savegame_file.find { |save| save[:id] == input.to_s }
  end

  def save_idx(input)
    savegame_file.index(savegame_by_id(input))
  end

  def save_game(to_save)
    save_id = to_save[:id]
    saves = savegame_file
    if save_exist?(save_id)
      saves[save_idx(save_id)] = savegame_by_id(save_id).merge(to_save)
      saves
    else
      saves << to_save
    end
    write_save_to_file(saves)
  end

  def save_exist?(save_id)
    true if savegame_file.any? { |save| save[:id] == save_id }
  end

  def write_save_to_file(input)
    File.open(SAVEFILE, 'w') { |file| file.write(input.to_json) }
  end

  def list_saved_games
    savegame_file.each do |save|
      puts "ID: #{save[:id]} | Player: #{save[:player]} | Guessed: #{save[:guessed_letters].join} | Used: #{save[:used_letters].join(', ')} | Moves remaining: #{save[:remaining_moves]}"
    end
  end

  def load_game(input)
    Game.new(savegame_by_id(input)).play
  end

  def delete_game(input)
    saves = savegame_file
    saves.delete(savegame_by_id(input))
    write_save_to_file(saves)
  end
end
