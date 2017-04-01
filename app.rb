# app/app.rb
require 'sinatra/base'
require 'sprockets'
require 'uglifier'
require 'sass'
require 'coffee-script'
require 'execjs'
require 'v8'
require_relative 'models/game'

class ApplicationController < Sinatra::Base
  # initialize new sprockets environment
  set :environment, Sprockets::Environment.new

  configure do
    use Rack::Session::Cookie, key: 'rack.session',
                               path: '/',
                               expire_after: 2_592_000
  end

  # append assets paths
  environment.append_path 'assets/stylesheets'
  environment.append_path 'assets/js'
  environment.append_path 'assets/img'

  # compress assets
  environment.js_compressor  = :uglify
  environment.css_compressor = :sass

  # get assets
  get '/assets/*' do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end

  # routes
  get '/' do
    slim :index
  end

  get '/new-game' do
    slim :new_game
  end

  get '/load-game' do
    @saved= SaveLoad.new.saved_games
    slim :load_game
  end

  get '/new/?:id?' do
    session[:name] = params[:name] unless params[:name].nil?
    load_game_data = SaveLoad.new.savegame_by_id(params[:id]) || { player: session[:name] }

    @game = Game.new(load_game_data)
    @player = @game.player

    session[:game] = @game

    slim :new
  end

  post '/guess' do
    letter = params[:guess]
    return session[:game].json_response.to_json if letter.empty?
    session[:game].good_guess(letter)
    session[:game].json_response.to_json
  end
end
