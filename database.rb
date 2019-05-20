module Model
    # Loads the databse
    #
    def connect 
        Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/data.db')
    end

    # Hashes inputpassword and compares it to the hash in database
    #
    # @param [String] pw The password from user input
    # @param [String] dbpw The hash from database
    #
    # @return [TrueClass] If the passwords match
    # @return [FalseClass] If the passwords dont match
    def checkpassword(pw,dbpw)
        if BCrypt::Password.new(dbpw) == pw
            return true
        else
            return false
        end
    end

    # Validates an img file, writes the file and inserts the path to the datebase
    #
    # @param [Hash] params 
    def newimg(params)
        db = connect()
        if params[:img] == nil
            return false
        end
        imgname = params[:img][:filename]
        img = params[:img][:tempfile]
        imgvalidate = imgname =~ /.(jpg|bmp|png|jpeg)$/
        if imgvalidate != nil
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
            if element == nil
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
            return result[:UserName]
        else
            return false
        end
    end

    def editprofile(params)
        db = connect()
        dbhash = db[:users].first(:Id => 1)
        if checkpassword(params["oldpw"],dbhash[:Hash]) == true
            if params["newpw1"] == params["newpw2"]
                hash = BCrypt::Password.create(params["newpw2"])
                db[:users].where(Id: 1).update(Hash: hash)
                return true
            else
                return "Nya lösenordet matchar inte!"
            end
        else
            return "Fel nuvarande lösenord!"
        end
    end
    # -------------------------Employees-------------------------

    def validate_employee(params)
        val = {}
        val[:firstnamevalidate] = params["FirstName"] =~ /^[a-öA-ÖåäöÅÄÖ]{2,}$/
        val[:lastnamevalidate] = params["LastName"] =~ /^[a-öA-ÖåäöÅÄÖ]{3,}$/
        val[:emailvalidate] = params["Email"] =~ /\A([a-zA-Z\d].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/
        val[:phonevalidate] = params["Phone"] =~ /^\+?\d{10,}$/
        if params["Info"].strip.empty? == true
            val[:infovalidate] = nil
        else
            val[:infovalidate] = 0
        end
        if validate(val) == false
            return "Vänligen fyll i alla fält korrekt"
        else
            return true
        end
    end

    def getemployees(params)
        db = connect()
        db[:employees].join(:images, :ImgId => :ImgId)
    end

    def newemployee(params)
        db = connect()
        result = validate_employee(params)
        img = newimg(params)
        if result != true
            return result
        elsif img == false
            return "Vänligen ladda upp en bild!"
        else
            db[:employees].insert(Firstname: "#{params["FirstName"]}", LastName: "#{params["LastName"]}", Email: "#{params["Email"]}", Phone: "#{params["Phone"]}", Info: "#{params["Info"]}", ImgId: "#{img}")
            return true
        end
    end

    def editemployee(params)
        db = connect()
        db[:employees].where(Id: params["id"])
    end

    def updateemployee(params)
        db = connect()
        result = validate_employee(params)
        if result != true
            return result
        end
        if params[:img] != nil
            imgid = newimg(params)
            db[:employees].where(Id: params["id"]).update(Firstname: "#{params["FirstName"]}", LastName: "#{params["LastName"]}", Email: "#{params["Email"]}", Phone: "#{params["Phone"]}", Info: "#{params["Info"]}", ImgId: "#{imgid}")
        else
            db[:employees].where(Id: params["id"]).update(Firstname: "#{params["FirstName"]}", LastName: "#{params["LastName"]}", Email: "#{params["Email"]}", Phone: "#{params["Phone"]}", Info: "#{params["Info"]}")
        end
        # return true
    end

    def removeemployee(params)
        db = connect()
        db[:employees].where(Id: params["id"]).delete
    end

    #-------------------------------------------------------------
    
    #---------------------------Posts------------------------------------
    def validate_post(params)
        val = {}
        val[:titlevalidate] = params["PostTitle"] =~ /^[a-öA-ÖåäöÅÄÖ]{6,}$/
        if params["PostText"].strip.empty? == true
            val[:textvalidate] = nil
        else
            val[:textvalidate] = 0
        end
        if validate(val) == false
            return "Vänligen fyll i alla fält korrekt!"
        else
            return true
        end
    end

    def getnews(params)
        db = connect()
        return db[:posts].join(:images, :ImgId => :ImgId).order(Sequel.desc(:Id))
    end

    def newpost(params)
        db = connect()
        result = validate_post(params)
        img = newimg(params)
        if result != true
            return result
        elsif img == false
            return "Vänligen ladda upp en bild!"
        else
            db[:posts].insert(PostTitle: "#{params["PostTitle"]}", PostText: "#{params["PostText"]}", ImgId: "#{img}", PostDate: Date.today)
            return true
        end
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
        result = validate_post(params)
        if result != true
            return result
        end
        if params[:img] != nil
            imgid = newimg(params)
            db[:posts].where(Id: params["id"]).update(PostTitle: "#{params["PostTitle"]}", PostText: "#{params["PostText"]}", ImgId: "#{imgid}", PostDate: Date.today)
        else
            db[:posts].where(Id: params["id"]).update(PostTitle: "#{params["PostTitle"]}", PostText: "#{params["PostText"]}", PostDate: Date.today)
        end
        return true
    end
    #---------------------------------------------------------
end