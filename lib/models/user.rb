require 'mongoid'

class User
  include Mongoid::Document
  field :name
  field :login
  embeds_many :recipes
end

class Recipe
  include Mongoid::Document
  field :name
  embedded_in :user, :inverse_of => :recipes
end 



