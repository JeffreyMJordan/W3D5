require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @class_name = options[:class_name] || name.to_s.capitalize
    @primary_key = options[:primary_key] || :id
    
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})

    @foreign_key = options[:foreign_key] || "#{self_class_name.singularize.downcase}_id".to_sym
    @class_name = options[:class_name] || name.to_s.capitalize.singularize
    @primary_key = options[:primary_key] || :id
    
  end
end

module Associatable
  # Phase IIIb
  
  def belongs_to(name, options = {})
    optionss = BelongsToOptions.new(name, options)
    self.assoc_options[name] = optionss
    define_method(name) do
      object = optionss.model_class
      hash = {}
      
      thing = object.where({id: self.send(optionss.foreign_key)})
      thing.first

    end
  end

  def has_many(name, options = {})

    optionss = HasManyOptions.new(name, self.name, options)
    self.assoc_options[name] = optionss
    define_method(name) do
      
      object = optionss.model_class
      key = optionss.foreign_key
      
      thing = object.where({"#{key}".to_sym =>  self.id})
      thing

    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable

end





















