class Dog
  attr_accessor :id, :name, :breed
  def initialize(id: id, name: name, breed: breed)
    @id, @name, @breed = id, name, breed
  end
  
  def self.create_table
    DB[:conn].execute <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
  end
  
  def self.drop_table
    DB[:conn].execute "DROP TABLE IF EXISTS dogs;"
  end
    def self.new_from_db(row)
    dog = self.new(**[:id, :name, :breed].zip(row).to_h)
    dog
  end
    def self.find_by_name(name)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
    unless result.empty?
      new_from_db(result.first)
    else
      nil
    end
  end
  
  def update
    save
  end
  
  def self.find_by_id(id)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)
    unless result.empty?
      new_from_db(result.first)
    else
      nil
    end
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          AND breed = ?
          LIMIT 1
        SQL

    dog = DB[:conn].execute(sql,name,breed)

    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
  
  def self.create(**attrs)
    dog = new(**attrs)
    dog.save
    dog
  end
  
  def save
    if @id.nil?
      sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
      SQL
  
      DB[:conn].execute(sql, self.name, self.breed)
      
      @id = DB[:conn].execute("SELECT id FROM dogs WHERE name = ?", @name).first.first
    else
      sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ?
      SQL
      
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    
    self
  end
end