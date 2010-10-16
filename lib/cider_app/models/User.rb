class User
  include Mongoid::Document
  field :name
  embeds_many :recipes

  #after_create :setup_default_recipes

  def self.get(username)
    user = User.first(:conditions => {:name => username})

    user = User.create(:name => username) if user.nil?
    user
  end

  def run_list=(run_list)
    recipes.delete_all
    #pp recipes
    run_list.each do |recipe_name|
      recipes << Recipe.new(:name => recipe_name)
    end
    #pp recipes
    save
  end

  private
  def setup_default_recipes
    run_list = ["ruby", "ruby::irbrc", "node", "python", "erlang"]
  end
end

class Recipe
  include Mongoid::Document
  field :name
  embedded_in :user, :inverse_of => :recipes
end
