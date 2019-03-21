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

post('/login') do
    if login(params) == true
        redirect('/dashboard')
    else
        session[:wrong] = true
        redirect('/')
    end
end

get('/dashboard') do
    slim(:index)
end
