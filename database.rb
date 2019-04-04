def getdb()
    db = SQLite3::Database.new("db/data.db")
    db.results_as_hash = true
    return db
end

def checkpassword(pw,dbpw)
    if BCrypt::Password.new(dbpw) == pw
        return true
    else
        return false
    end
end

def login(params)
    db = getdb()
    result = db.execute("SELECT Id, UserName, Hash FROM users WHERE Username =?",params["UserName"])
    if result == []
        return false
    elsif checkpassword(params["PassWord"],result[0]["Hash"]) == true
        session[:userid] = result[0]["Id"]
        session[:username] = result[0]["UserName"]
        return true
    else
        return false
    end
end

def editprofile(params)
    db = getdb()
    dbhash = db.execute("SELECT Hash FROM users WHERE id = 1")
    if checkpassword(params["oldpw"],dbhash[0]["Hash"]) == true
        if params["newpw1"] == params["newpw1"]
            hash = BCrypt::Password.create(params["newpw2"])
            db.execute("UPDATE users SET Hash = ? WHERE Id = ?",hash,1)
            return true
        else
            return false
        end
    else
        return false
    end
end

def getnews(params)
    db = getdb()
    return db.execute("SELECT * FROM posts")
end

def newpost
    
end

def getemployees(params)
    
end