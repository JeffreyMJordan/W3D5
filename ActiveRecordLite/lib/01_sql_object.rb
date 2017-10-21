require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
require_relative '02_searchable'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  

  def self.columns
    return @columns if @columns
    res = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      SQL

    @columns = res.first.map{|key| key.to_sym}


  end

  def self.finalize!
    self.columns.each do |k| 
      
      define_method(k) do 
        self.attributes[k]
      end

      define_method("#{k}=") do |value| 
        self.attributes[k]=value 
      end
    end

  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.to_s.tableize
  end

  def self.all
    
    res = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      SQL
    @all = self.parse_all(res)
  end

  def self.parse_all(results)
    results.map{|el| self.new(el)}
  end

  def self.find(id)
    return nil if !id 
    res = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE 
        id=#{id}
      SQL
    self.parse_all(res).first
  end

  def initialize(params = {})

    params.each do |k,v| 
      k = k.to_sym
      raise "unknown attribute \'#{k}\'" if !self.class.columns.include?(k)
      self.send("#{k}=", v)
    end
  end

  def attributes
    return @attributes if @attributes
    @attributes = {}
    @attributes
  end

  def attribute_values
    @attributes.values
  end

  def insert
    
    cols = self.class.columns.drop(1)
    question_marks = (["?"]*cols.length).join(", ")
    
    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO 
        #{self.class.table_name} (#{cols.map{|el| el.to_s}.join(", ")})
      VALUES 
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
    nil 

  end

  def update
    str = self.class.columns.drop(1).map{|el| "#{el}=? "}.join(", ")
    temp = attribute_values.drop(1)
    
    DBConnection.execute(<<-SQL, temp)
    UPDATE 
      #{self.class.table_name}
    SET 
      #{str}
    WHERE
      id=#{self.id}
    SQL
  end

  def save
    if self.id==nil 
      insert
    else 
      update
    end
  end
end
