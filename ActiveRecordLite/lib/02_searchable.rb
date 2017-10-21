require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

module Searchable
  def where(params)
    
    str = params.keys.map{|el| "#{el} = ? "}.join(" AND ")
    
    arr = DBConnection.execute(<<-SQL, params.values)
      SELECT * 
      FROM 
        #{self.table_name}
      WHERE 
        #{str}
    SQL

    arr.map{|el| self.new(el)}
    
  end


  
end

class SQLObject
  extend Searchable
end