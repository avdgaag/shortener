require 'rubygems'
require 'sinatra'
require 'shortener'
set :environment, :production
run Sinatra::Application