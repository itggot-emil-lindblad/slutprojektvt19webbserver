require 'sinatra'
require 'securerandom'
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

include Model

# Display landing page
#
get('/') do
    if session[:username] == nil
        slim(:login, layout: :loginlayout)
    else
        redirect('/dashboard')
    end
end

# Attempts to login and updates the session
#
# @param [String] UserName, The username
# @param [String] PassWord, The password
#
# @see Model#login
post('/login') do
    login = login(params)
    if login != false
        session[:username] = login
        redirect('/dashboard')
    else
        set_error("Fel användarnamn eller lösenord!")
        redirect('/')
    end
end

# Displays main page when authenticated
#
get('/dashboard') do
    slim(:index)
end

# Kills the session and logs out
#
post('/logout') do
    session.destroy
    redirect('/')
end

# Displays news page
#
# @see Model#getnews
get('/news') do
    newsposts = getnews()
    slim(:news, locals:{
            newsposts: newsposts
        }
    )
end

# Displays a form for creating a new post
#
# @ see Model#getcategories
get('/newpost') do
    categories = getcategories()
    slim(:newpost, locals:{
            categories: categories
        }
    )
end

# Takes input and attempts to create a new post
#
# @param [String] PostTitle, The post title
# @param [String] PostText, The post text
# @param [File] img, A uploaded image
#
# @see Model#newpost
post('/newpost') do
    result = newpost(params)
    if result == true
        redirect('/news')
    else
        set_error(result)
        redirect('/newpost')
    end
end

# Displays a form for editing a specific post
#
# @param [Integer] :id, The ID of the post
#
# @see Model#editpost
# @see Model#getcategories
get('/editpost/:id') do
    post = editpost(params)
    categories = getcategories()
    categoriesid = getcategoriesforedit(params)
    slim(:editpost, locals: {
            post: post,
            categories: categories,
            categoriesid: categoriesid
        }
    )
end

# Takes input and attempts to edit a specific new post
#
# @param [Integer] :id, The ID of the post
# @param [String] PostTitle, The post title
# @param [String] PostText, The post text
# @param [String] img, The post image
# @param [String] Category1, The first post category
# @param [String] Category2, The secound post category
#
# @see Model#updatepost
post('/editpost/:id/update') do
    result = updatepost(params)
    if result == true
        redirect('/news')
    else
        set_error(result)
        redirect(back)
    end
end

# Deletes a post
#
# @param [Integer] :id, The ID of the post
#
# @see Model#deletepost
post('/editpost/:id/delete') do
    deletepost(params)
    redirect('/news')
end

# Displays a form for chaning login password
#
get('/editprofile') do
    slim(:editprofile)
end

# Changes login password
#
# @param [String] oldpw, The old password
# @params [String] newpw1, The new password
# @params [String] newpw2, The repated new password
#
# @see Model#editprofile
post('/editprofile/update') do
    output = editprofile(params)
    if output != true
        set_error(output)
        redirect(back)
    else
        set_error("Lösenordsbyte lyckades!")
        redirect(back)
    end
end

# Displays a page with all employees
#
# @see Model#getemployees
get('/employees') do
    employees = getemployees()
    slim(:employees, locals:{
            employees: employees
        }
    )
end

# Displays a form for creating a new employee profile
#
get('/newemployee') do
    slim(:newemployee)
end

# Takes input and attempts to create a new employee profile
#
# @param [String] FirstName, The first name of the employee
# @param [String] LastName, The last name of the employee 
# @param [String] Email, The email of the employee
# @param [String] Phone, The phone number of the employee
# @param [String] Info, General information of the employee
#
# @see Model#newemployee
post('/newemployee') do
    result = newemployee(params)
    if result == true
        redirect('/employees')
    else
        set_error(result)
        redirect('/newemployee')
    end
end

# Displays a form for editing a specific employee profile
#
# @param [Integer] :id, The ID of the employee
#
# @ see Model#editemployee
get('/editemployee/:id') do
    employee = editemployee(params)
    slim(:editemployee, locals:{
            employee: employee
        }
    )
end

# Takes input and attempts to edit a specific employee profile
#
# @param [Integer] :id, The id of the employee profile
# @param [String] FirstName, The first name of the employee
# @param [String] LastName, The last name of the employee 
# @param [String] Email, The email of the employee
# @param [String] Phone, The phone number of the employee
# @param [String] Info, General information of the employee
#
# @see Model#updateemployee
post('/editemployee/:id/update') do
    result = updateemployee(params)
    if result == true
        redirect('/employees')
    else
        set_error(result)
        redirect(back)
    end
end

# Deletes an employee profile
#
# @param [Integer] :id, The ID of the employee profile
#
# @see Model#removeemployee
post('/editemployee/:id/delete') do
    removeemployee(params)
    redirect('/employees')
end

# Displays a form for creating a new post category
#
# @see Model#getcategories
get('/categories') do
    categories = getcategories()
    slim(:categories, locals:{
            categories: categories
        }
    )
end

# Takes input and attempts to create a new post category
#
# @param [String] Category, The name of the category
#
# @see Model#newcategory
post('/newcategory') do
    result = newcategory(params)
    set_error(result)
    redirect(back)
end

# Deletes an employee profile
#
# @param [String] Category, The id of the category
#
# @see Model#removecategory
post('/removecategory') do
    removecategory(params)
    redirect(back)
end