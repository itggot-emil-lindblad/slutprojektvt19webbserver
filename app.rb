require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
require 'securerandom'
require_relative 'database.rb'

enable :sessions

get('/') do
    slim(:login)
end