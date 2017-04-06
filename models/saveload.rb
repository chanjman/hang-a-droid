# Saves and loads the game
class SaveLoad
  SAVEFILE = (Dir.pwd + '/saves/saves.json').freeze

  def saved_games
    JSON.parse(File.open(SAVEFILE).read, symbolize_names: true)
  end

  def savegame_by_id(input)
    saved_games.find { |save| save[:id] == input.to_s }
  end

  def save_idx(input)
    saved_games.index(savegame_by_id(input))
  end

  def save_game(to_save)
    save_id = to_save[:id]
    saves = saved_games
    if save_exist?(save_id)
      saves[save_idx(save_id)] = savegame_by_id(save_id).merge(to_save)
      saves
    else
      saves << to_save
    end
    write_save_to_file(saves)
  end

  def save_exist?(save_id)
    true if saved_games.any? { |save| save[:id] == save_id }
  end

  def write_save_to_file(input)
    File.open(SAVEFILE, 'w') { |file| file.write(input.to_json) }
  end

  def load_game(input)
    Game.new(savegame_by_id(input))
  end

  def delete_game(input)
    saves = saved_games
    saves.delete(savegame_by_id(input))
    write_save_to_file(saves)
  end

  def delete_all
    write_save_to_file(saved_games.clear)
  end
end
