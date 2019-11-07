require_relative '../config/environment.rb'

class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(pair, id = nil) #({name: "Kevin", breed "shepard", 1})
        @name = pair[:name]
        @breed = pair[:breed]
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        ) 
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs(name, breed)
            VALUES (?, ?)
            SQL

            DB[:conn].execute(sql,self.name, self.breed)
            @id = DB[:conn].execute("SELECT Last_Insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
    end

    def self.new_from_db(array)
        #[1, "Kevin", "shepard"]
        id = array[0]   #1
        pair = {name: array[1], breed: array[2]}   #{name: "Kevin", breed: "shepard"}
        dog = Dog.new(pair, id)  #({name: "Kevin", breed "shepard", 1})
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * 
        FROM dogs 
        WHERE id = ?
        SQL
        
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end 

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL

        DB[:conn].execute(sql,name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        exists = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if exists.empty?
            hash = {name: name, breed: breed}
           dog = self.create(hash)
        else
            dog_info = exists[0]
            doghash = {name: dog_info[1], breed: dog_info[2]}
            dog = Dog.new(doghash, dog_info[0])
        end
    end

    def update
        sql="UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end 
end