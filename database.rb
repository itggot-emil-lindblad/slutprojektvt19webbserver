# def getdb()
#     db = SQLite3::Database.new("db/data.db")
#     db.results_as_hash = true
# end

DB = Sequel.connect('sqlite://db/data.db')

def checkpassword(pw,dbpw)
    if BCrypt::Password.new(dbpw) == pw
        return true
    else
        return false
    end
end

def login(params)
    result = DB[:users].first(:UserName => params["UserName"])
    if result == nil
        return false
    elsif checkpassword(params["PassWord"],result[:Hash]) == true
        session[:username] = result[:UserName]
        return true
    else
        return false
    end
end

# def login(params)
#     db = getdb()
#     result = db.execute("SELECT Id, UserName, Hash FROM users WHERE Username =?",params["UserName"])
#     if result == []
#         return false
#     elsif checkpassword(params["PassWord"],result[0]["Hash"]) == true
#         # session[:userid] = result[0]["Id"]
#         session[:username] = result[0]["UserName"]
#         return true
#     else
#         return false
#     end
# end

def editprofile(params)
    dbhash = DB[:users].first(:Id => 1)
    if checkpassword(params["oldpw"],dbhash[:Hash]) == true
        if params["newpw1"] == params["newpw1"]
            hash = BCrypt::Password.create(params["newpw2"])
            DB[:users].where(Id: 1).update(Hash: hash)
            return true
        else
            return false
        end
    else
        return false
    end
end

# def editprofile(params)
#     db = getdb()
#     dbhash = db.execute("SELECT Hash FROM users WHERE id = 1")
#     if checkpassword(params["oldpw"],dbhash[0]["Hash"]) == true
#         if params["newpw1"] == params["newpw1"]
#             hash = BCrypt::Password.create(params["newpw2"])
#             db.execute("UPDATE users SET Hash = ? WHERE Id = ?",hash,1)
#             return true
#         else
#             return false
#         end
#     else
#         return false
#     end
# end

def getnews(params)
    return DB[:posts].order(Sequel.desc(:Id))
end

# def getnews(params)
#     db = getdb()
#     return db.execute("SELECT * FROM posts ORDER BY Id DESC")
# end

def newpost(params)
    # imgname = params[:img][:filename]
    # img = params[:img][:tempfile]
    DB[:posts].insert(PostTitle: "#{params["PostTitle"]}", PostText: "#{params["PostText"]}", ImgPath: "Banan", PostDate: Date.today)
end

def deletepost(params)
    DB[:posts].where(Id: params["id"]).delete
end

def editpost(params)
    DB[:posts].where(Id: params["id"])
end

def updatepost(params)
    DB[:posts].where(Id: params["id"]).update(PostTitle: "#{params["PostTitle"]}", PostText: "#{params["PostText"]}", ImgPath: "Banan", PostDate: Date.today)
end

def getemployees(params)
    DB[:employees].all
end

def newemployee(params)
    DB[:employees].insert(Firstname: "#{params["FirstName"]}", LastName: "#{params["LastName"]}", Email: "#{params["Email"]}", Phone: "#{params["Phone"]}", Info: "#{params["Info"]}")
end

def editemployee(params)
    DB[:employees].where(Id: params["id"])
end

def updateemployee(params)
    DB[:employees].where(Id: params["id"]).update(Firstname: "#{params["FirstName"]}", LastName: "#{params["LastName"]}", Email: "#{params["Email"]}", Phone: "#{params["Phone"]}", Info: "#{params["Info"]}")
end
