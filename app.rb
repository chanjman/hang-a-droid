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
    slim :load_game
  end
end
