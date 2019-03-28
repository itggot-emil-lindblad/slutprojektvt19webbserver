def getdb()
    db = SQLite3::Database.new("db/data.db")
    db.results_as_hash = true
    return db
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

def checkpassword(pw,dbpw)
	if BCrypt::Password.new(dbpw) == pw
		return true
    else
        return false
    end
end

def news(params)
    db = getdb()
    return db.execute("SELECT * FROM posts")
end

def editprofile(params)
    db = getdb()
    if params["oldpw"] == db.execute("")
        if params["newpw1"] == params["newpw1"]
            hash = BCrypt::Password.create(params["newpw2"])
        end
    end
end