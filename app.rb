require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
require 'securerandom'
require 'sequel'
require_relative 'database.rb'
enable :sessions


configure do
    set :bind, '0.0.0.0'
    set :publicroutes, ["/","/login","/logout"]
end

before do 
    if settings.publicroutes.any?(request.path_info) == false
        if session[:username] != nil
            break
        else
            halt 401
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

error 401 do 
    'Unauthorized!'
end

get('/') do
    if session[:username] == nil
        slim(:login)
    else
        redirect('/dashboard')
    end
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
    session.destroy
    redirect('/')
end

get('/news') do
    newsposts = getnews(params)
    slim(:news, locals:{newsposts: newsposts})
end

get('/newpost') do
    slim(:newpost)
end

post('/newpost') do
    newpost(params)
    redirect('/news')
end

get('/editpost/:id') do
    slim(:editpost)
end

get('/editprofile') do
    slim(:editprofile)
end

post('/editprofile/update') do 
    editprofile(params)
    redirect('/dashboard')
end

get('/employees') do
    getemployees(params)
    slim(:employees)
end