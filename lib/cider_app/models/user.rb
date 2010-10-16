class User
  include Mongoid::Document
  field :name
  embeds_many :recipes

  after_create :setup_default_recipes

  def self.get(username)
    if user = User.first(:conditions => {:name => username})
      user
    else
      User.create(:name => username) if user.nil?
    end
  end

  def run_list
    recipes.map { |recipe| recipe.name }
  end

  def run_list=(new_run_list)
    recipes.delete_all
    new_run_list.each do |recipe_name|
      recipes << Recipe.new(:name => recipe_name)
    end
    save
  end

  private
    def setup_default_recipes
      self.run_list = ["ruby", "ruby::irbrc", "node", "python", "erlang"]
    end
end

class Recipe
  include Mongoid::Document
  field :name
  embedded_in :user, :inverse_of => :recipes
end
