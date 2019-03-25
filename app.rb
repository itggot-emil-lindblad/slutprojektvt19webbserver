require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
require 'securerandom'
require_relative 'database.rb'
enable :sessions

configure do
    set :publicroutes, ["/","/login","/logout"]
end

before do 
    if settings.publicroutes.any?(request.path_info) == false
        if session[:username] != nil
            break
        else
            halt 401, 'Unauthorized Error 401'
        end
    end
end

helpers do
    def set_error(msg)
        session[:error] = msg
    end
    
    def get_error()
        error = session[:error]
        session[:error] = nil
        return error
    end
    
    def error?
        !session[:error].nil?
    end
end

get('/') do
    slim(:login)
end

post('/login') do
    if login(params) == true
        redirect('/dashboard')
    else
        set_error("Fel användarnamn eller lösenord!")
        redirect('/')
    end
end

get('/dashboard') do
    slim(:index)
end

post('/logout') do
    p session
    session.destroy
    p session
    redirect('/')
end
