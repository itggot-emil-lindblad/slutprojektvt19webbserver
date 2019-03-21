require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
require 'securerandom'
require_relative 'database.rb'

get('/') do
    slim(:login)
end

post('/login') do
    if login(params) == true
        redirect('/dashboard')
    else
        redirect('/denied')
    end
end

get('/dashboard') do
    slim(:index)
end

get('/denied') do
    "Error 501"
end