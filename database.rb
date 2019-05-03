def connect 
     Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/data.db')
end

def checkpassword(pw,dbpw)
    if BCrypt::Password.new(dbpw) == pw
        return true
    else
        return false
    end
end

def newimg(params)
    db = connect()
    imgname = params[:img][:filename]
    img = params[:img][:tempfile]
    validate = imgname =~ /.(jpg|bmp|png|jpeg)$/
    if validate != nil
        newname = SecureRandom.hex(10) + imgname.match(/.(jpg|bmp|png|jpeg)$/)[0]
        File.open("public/img/#{newname}", 'wb') do |f|
            f.write(img.read)
        end
    end
    db[:images].insert(Path: "#{newname}")
    return db[:images].where(Path: "#{newname}").get(:ImgId)
end

def validate(params)
    params.values.each do |element|
        if element == ""
            return false
        end
    end
    return true
end

def login(params)
    db = connect()
    result = db[:users].first(:UserName => params["UserName"])
    if result == nil
        return false
    elsif checkpassword(params["PassWord"],result[:Hash]) == true
        session[:username] = result[:UserName]
        return true
    else
        return false
    end
end

def editprofile(params)
    db = connect()
    dbhash = db[:users].first(:Id => 1)
    if checkpassword(params["oldpw"],dbhash[:Hash]) == true
        # byebug
        if params["newpw1"] == params["newpw2"]
            hash = BCrypt::Password.create(params["newpw2"])
            db[:users].where(Id: 1).update(Hash: hash)
            return true
        else
            return "Nomatch"
        end
    else
        return "Wrong pw"
    end
end

def getnews(params)
    db = connect()
    return db[:posts].join(:images, :ImgId => :ImgId).order(Sequel.desc(:Id))
end

def newpost(params)
    db = connect()
    imgid = newimg(params)
    db[:posts].insert(PostTitle: "#{params["PostTitle"]}", PostText: "#{params["PostText"]}", ImgId: "#{imgid}", PostDate: Date.today)
end

def deletepost(params)
    db = connect()
    db[:posts].where(Id: params["id"]).delete
end

def editpost(params)
    db = connect()
    db[:posts].join(:images, :ImgId => :ImgId).where(Id: params["id"])
end

def updatepost(params)
    db = connect()
    if params[:img] != nil
        imgid = newimg(params)
        db[:posts].where(Id: params["id"]).update(PostTitle: "#{params["PostTitle"]}", PostText: "#{params["PostText"]}", ImgId: "#{imgid}", PostDate: Date.today)
    else
        db[:posts].where(Id: params["id"]).update(PostTitle: "#{params["PostTitle"]}", PostText: "#{params["PostText"]}", PostDate: Date.today)
    end
end

def getemployees(params)
    db = connect()
    db[:employees].join(:images, :ImgId => :ImgId)
end

def newemployee(params)
    db = connect()
    imgid = newimg(params)
    db[:employees].insert(Firstname: "#{params["FirstName"]}", LastName: "#{params["LastName"]}", Email: "#{params["Email"]}", Phone: "#{params["Phone"]}", Info: "#{params["Info"]}", ImgId: "#{imgid}")
end

def editemployee(params)
    db = connect()
    db[:employees].where(Id: params["id"])
end

def updateemployee(params)
    db = connect()
    if params[:img] != nil
        imgid = newimg(params)
        db[:employees].where(Id: params["id"]).update(Firstname: "#{params["FirstName"]}", LastName: "#{params["LastName"]}", Email: "#{params["Email"]}", Phone: "#{params["Phone"]}", Info: "#{params["Info"]}", ImgId: "#{imgid}")
    else
        db[:employees].where(Id: params["id"]).update(Firstname: "#{params["FirstName"]}", LastName: "#{params["LastName"]}", Email: "#{params["Email"]}", Phone: "#{params["Phone"]}", Info: "#{params["Info"]}")
    end
end

def removeemployee(params)
    db = connect()
    db[:employees].where(Id: params["id"]).delete
end
