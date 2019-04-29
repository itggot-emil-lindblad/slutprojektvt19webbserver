require 'sinatra'
require_relative 'database.rb'
require_relative 'render.rb'
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
        slim(:login, layout: :loginlayout)
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
    slim(:news, locals:{
            newsposts: newsposts
        }
    )
end

get('/newpost') do
    slim(:newpost)
end

post('/newpost') do
    newpost(params)
    redirect('/news')
end

get('/editpost/:id') do
    post = editpost(params)
    slim(:editpost, locals: {
            post: post
        }
    )
end

post('/editpost/:id/update') do
    updatepost(params)
    redirect('/news')
end

post('/editpost/:id/delete') do
    deletepost(params)
    redirect('/news')
end

get('/editprofile') do
    slim(:editprofile)
end

post('/editprofile/update') do 
    editprofile(params)
    redirect('/dashboard')
end

get('/employees') do
    employees = getemployees(params)
    slim(:employees, locals:{
            employees: employees
        }
    )
end

get('/newemployee') do
    slim(:newemployee)
end

post('/newemployee') do
    newemployee(params)
    redirect('/employees')
end

get('/editemployee/:id') do
    employee = editemployee(params)
    slim(:editemployee, locals:{
            employee: employee
        }
    )
end

post('/editemployee/:id/update') do
    updateemployee(params)
    redirect('/employees')
end

post('/editemployee/:id/delete') do
    removeemployee(params)
    redirect('/employees')
end