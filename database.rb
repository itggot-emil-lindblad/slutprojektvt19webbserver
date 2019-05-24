module Model
    # Loads the databse
    #
    # @return A connection to the database
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

    # Validates an uploaded file, writes the file and inserts the path to the database
    #
    # @param [Hash] params form data
    # @option params [String] img The uploaded file
    #
    # @return [Integer] if an image was created
    # @return [FalseClass] if validation of the uploaded file failed
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
            db[:images].insert(Path: "#{newname}")
            return db[:images].where(Path: "#{newname}").get(:ImgId)
        else
            return false
        end
    end
    
    # Checks if keys in a class are false
    #
    # @param [Hash] params validation keys
    # @option params [Boolean] firstnamevalidate First name validation
    # @option params [Boolean] lastnamevalidate Last name validation
    # @option params [Boolean] emailvalidate Email validation
    # @option params [Boolean] phonevalidate Phone validation
    #
    # @return [TrueClass] if all keys are not false
    # @return [Falseclass] if some key is false
    def validate(params)
        params.values.each do |element|
            if element == nil
                return false
            end
        end
        return true
    end

    # Attempts to authenticate the user
    #
    # @param [Hash] params form data
    # @option params [String] UserName The submitted username
    # @option params [String] PassWord The submitted password
    #
    # @return [String] If authentication was successful
    # @return [FalseClass] If authentication failed
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

    # Attempts to change password
    #
    # @param [Hash] params form data
    # @option params [String] oldpw The current password
    # @option params [String] newp1 The new password
    # @option params [String] newpw2 The new password
    #
    # @return [TrueClass] if password change was successful
    # @return [String] if password change failed
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

    # Validates user input when creating a new employee profile
    #
    # @param [Hash] params form data
    # @option params [String] FirstName First name
    # @option params [String] LastName Last name
    # @option params [String] Email Email addess
    # @option params [String] Phone Phone numver
    #
    # @return [TrueClass] if validation was successful
    # @return [String] if valdation was failed
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

    # Retrieves all rows from employee table
    #
    # @return [Hash]
    #   * :Id [Integer] The id of the profile
    #   * :FirstName [String] The first name of the employee
    #   * :LastName [String] The last name of the employee
    #   * :Email [String] The email adress of the employee
    #   * :Phone [String] The phone number of the employee
    #   * :Info [String] General info about the employee
    #   * :Path [String] File path to the profile picture
    def getemployees()
        db = connect()
        db[:employees].join(:images, :ImgId => :ImgId)
    end

    # Attempts to insert a new row in the employees table
    #
    # @param [Hash] params form data
    # @option params [String] FirstName The first name of the employee
    # @option params [String] LastName The last name of the employee
    # @option params [String] Email The email adress of the employee
    # @option params [String] Phone The phone number of the employee
    # @option params [String] Info General info about the employee
    # @option params [String] Path File path to the profile picture
    #
    # @return [TrueClass] if a new profile was created
    # @return [String] if creation failed
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

    # Retrieves a single row from the employees table
    #
    # @param [Hash] params form data
    # @option params [String] Id The id of the profile
    #
    # @return [Hash]
    #   * :Id [Integer] The id of the profile
    #   * :FirstName [String] The first name of the employee
    #   * :LastName [String] The last name of the employee
    #   * :Email [String] The email adress of the employee
    #   * :Phone [String] The phone number of the employee
    #   * :Info [String] General info about the employee
    def editemployee(params)
        db = connect()
        db[:employees].where(Id: params["id"])
    end

    # Attempts to update a single row in the employees table
    #
    # @param [Hash] params form data
    # @option params [String] FirstNameThe first name of the employee
    # @option params [String] LastName The last name of the employee
    # @option params [String] Email The email adress of the employee
    # @option params [String] Phone The phone number of the employee
    # @option params [String] Info General info about the employee
    # @option params [String] Path File path to the profile picture
    #
    # @return [TrueClass] if the update was successful
    # @return [String] if the update failed
    def updateemployee(params)
        db = connect()
        result = validate_employee(params)
        if result != true
            return result
        end
        if params[:img] != nil
            imgid = newimg(params)
            if imgid == false
                return "Vänligen ladda upp en bild!"
            else
            db[:employees].where(Id: params["id"]).update(Firstname: "#{params["FirstName"]}", LastName: "#{params["LastName"]}", Email: "#{params["Email"]}", Phone: "#{params["Phone"]}", Info: "#{params["Info"]}", ImgId: "#{imgid}")
            end
        else
            db[:employees].where(Id: params["id"]).update(Firstname: "#{params["FirstName"]}", LastName: "#{params["LastName"]}", Email: "#{params["Email"]}", Phone: "#{params["Phone"]}", Info: "#{params["Info"]}")
        end
        return true
    end

    # Attempts to delete a row from the employees table
    #
    # @param [Hash] params form data
    # @option params [Integer] Id The id of the profile
    def removeemployee(params)
        db = connect()
        db[:employees].where(Id: params["id"]).delete
    end

    #-------------------------------------------------------------
    
    #---------------------------Posts------------------------------------

    # Validates user input when creating a new post
    #
    # @param [Hash] params form data
    # @option params [String] PostTitle The post title
    # @option params [String] PostText The post text
    #
    # @return [TrueClass] if validation was successful
    # @return [String] if valdation was failed
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

    def getnews()
        db = connect()
        # return db[:posts].join(:images, ImgId: :ImgId).join(:categories, CategoryId: Sequel[:categorieslink][:CategoryId]).join(:categorieslink, PostId: Sequel[:posts][:Id]).order(Sequel.desc(:Id))
        return db[:posts].join(:images, ImgId: :ImgId).order(Sequel.desc(:Id))
        # db.execute("SELECT * from posts INNER JOIN images on posts.ImgId = images.ImgId INNER JOIN categories ON categorieslink.CategoryId = categories.CategoryId INNER JOIN categorieslink ON posts.Id = categorieslink.PostId  WHERE Id = 33")
    end

    # Retrieves all rows from categories table
    #
    # @return [Hash]
    #   * :Id [Integer] The id of category
    #   * :Category [String] The category
    def getcategories()
        db = connect()
        return db[:categories]
        # return db[:categories].join(:categorieslink, CategoryId: :CategoryId)
    end

    # Retrieves all single from categories table joined with categorieslink table
    #
    # @return [Hash]
    #   * :Id [Integer] The id of category
    #   * :Category [String] The category
    def getcategoriesforedit(params)
        db = connect()
        return db[:categories].join(:categorieslink, CategoryId: :CategoryId).where(PostId: params["id"])
    end

    # Attempts to insert a new row in the posts and categorieslink table
    #
    # @param [Hash] params form data
    # @option params [String] PostTitle The post title
    # @option params [String] PostText The post text
    # @option params [String] img The post image
    # @option params [String] Category1 The first post category
    # @option params [String] Category2 The secound post category
    #
    # @return [TrueClass] if a new post was created
    # @return [String] if creation failed
    def newpost(params)
        db = connect()
        result = validate_post(params)
        category = categorycheck(params)
        if category == false
            return "Välj två unika kategorier"
        elsif result != true
            return result
        end
        img = newimg(params)
        if img == false
            return "Vänligen ladda upp en bild!"
        else
            db[:posts].insert(PostTitle: "#{params["PostTitle"]}", PostText: "#{params["PostText"]}", ImgId: "#{img}", PostDate: Date.today)
            postid = db[:posts].order(:Id).last
            db[:categorieslink].multi_insert([{PostId: "#{postid[:Id]}", CategoryId: "#{params["Category1"]}"}, {PostId: "#{postid[:Id]}", CategoryId: "#{params["Category2"]}"}])
            return true
        end
    end

    # Attempts to update a row in the posts and categorieslink table
    #
    # @param [Hash] params form data
    # @option params [Integer] Id The id of the post
    # @option params [String] PostTitle The post title
    # @option params [String] PostText The post text
    # @option params [String] img The post image
    # @option params [String] Category1 The first post category
    # @option params [String] Category2 The secound post category
    #
    # @return [TrueClass] if the update was successful
    # @return [String] if the update failed
    def updatepost(params)
        db = connect()
        result = validate_post(params)
        category = categorycheck(params)
        if category == false
            return "Välj två unika kategorier"
        end
        if result != true
            return result
        end
        if params[:img] != nil
            imgid = newimg(params)
            if imgid == false
                return "Vänligen ladda upp en bild!"
            else
                db[:posts].where(Id: params["id"]).update(PostTitle: "#{params["PostTitle"]}", PostText: "#{params["PostText"]}", ImgId: "#{imgid}", PostDate: Date.today)
                db[:categorieslink].where(Id: params.keys[2]).update(CategoryId: "#{params[params.keys[2]]}")
                db[:categorieslink].where(Id: params.keys[3]).update(CategoryId: "#{params[params.keys[3]]}")  
            end
        else
            db[:posts].where(Id: params["id"]).update(PostTitle: "#{params["PostTitle"]}", PostText: "#{params["PostText"]}", PostDate: Date.today)
            db[:categorieslink].where(Id: params.keys[2]).update(CategoryId: "#{params[params.keys[2]]}")
            db[:categorieslink].where(Id: params.keys[3]).update(CategoryId: "#{params[params.keys[3]]}")
        end
        return true
    end
    
    # Attempts to delete a row from the posts table
    #
    # @param [Hash] params form data
    # @option params [Integer] Id The id of the post
    def deletepost(params)
        db = connect()
        db[:posts].where(Id: params["id"]).delete
    end

    # Retrieves a single row from the posts table
    #
    # @param [Hash] params form data
    # @option params [String] Id The id of the post
    #
    # @return [Hash]
    #   * :Id [Integer] The id of the post
    #   * :PostTile [String] The post title
    #   * :PostText [String] The post text
    def editpost(params)
        db = connect()
        db[:posts].join(:images, :ImgId => :ImgId).where(Id: params["id"])
        # return db[:posts].join(:images, ImgId: :ImgId).join(:categories, CategoryId: Sequel[:categorieslink][:CategoryId]).join(:categorieslink, PostId: Sequel[:posts][:Id]).where(Sequel[:posts][:Id] => params["id"])
    end
    #---------------------------------------------------------

    # Attempts to insert a new row in the categories table
    #
    # @param [Hash] params form data
    # @option params [String] Category The name of the category
    #
    # @return [TrueClass] if a new category was created
    # @return [String] if creation failed
    def newcategory(params)
        db = connect()
        result = validate_category(params)
        if result != true
            return result
        else
            db[:categories].insert(Category: params["Category"])
            return "Kategorin lades till"
        end
    end

    # Validates user input when creating a new category
    #
    # @param [Hash] params form data
    # @option params [String] Category The name of the category
    #
    # @return [TrueClass] if validation was successful
    # @return [String] if valdation was failed
    def validate_category(params)
        db = connect()
        r = db[:categories].first(Category: params["Category"])
        if r != nil
            return "Kategorin finns redan!"
        end
        val = {}
        val[:categoryvalidate] = params["Category"] =~ /^[a-öA-ÖåäöÅÄÖ]{3,}$/
        if validate(val) == false
            return "Vänligen fyll i fältet, minst 3 bokstäver!"
        else
            return true
        end
    end

    # Checks if two inputs are the same
    #
    # @param [Hash] params form data
    # @option params [String] Category1 The name of the first category
    # @option params [String] Category2 The name of the second category
    #
    # @return [TrueClass] if inputs dont match
    # @return [String] if inputs match
    def categorycheck(params)
        if params[params.keys[2]] == params[params.keys[3]]
            return false
        else
            return true
        end
    end

    # Attempts to delete a row from the categroies table
    #
    # @param [Hash] params form data
    # @option params [Integer] Id The id of the post
    def removecategory(params)
        db = connect()
        db[:categories].where(CategoryId: params["Category"]).delete
    end
end