require 'mongoid'

class User
  include Mongoid::Document
  field :name
  embeds_many :recipes

  def self.load_user(username)
    user = User.first(:conditions => {:name => username})
    
    if (user.nil?)
      user = User.new(:name => username)
      user.save
    end

    user
  end

  def update_recipes(recipe_list)
    recipes.delete_all     
      recipe_list.each do |recipe_name|
        recipes << Recipe.new(:name => recipe_name)
      end 
  end

end

class Recipe
  include Mongoid::Document
  field :name
  embedded_in :user, :inverse_of => :recipes

  
end 



