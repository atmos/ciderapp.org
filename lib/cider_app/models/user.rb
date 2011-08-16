class User
  include Mongoid::Document
  field :name
  embeds_many :recipes

  after_create :setup_default_recipes


  def self.default_recipes
    [ "homebrew", "homebrew::dbs", "homebrew::misc",
      "ruby", "ruby::rbenv", "node", "python", "erlang",
      "mvim::cli"
    ]
  end

  def self.optional_recipes
    [ "ruby", "ruby::rbenv", "node", "python", "erlang", "oh-my-zsh" ]
  end

  def self.get(username)
    if user = User.first(:conditions => {:name => username})
      user
    else
      User.create(:name => username) if user.nil?
    end
  end

  def run_list
    [ "homebrew", "homebrew::dbs", "homebrew::misc" ] +
      recipes.map { |recipe| recipe.name }
  end

  def run_list=(new_run_list)
    recipes.delete_all
    valid_new_runlist(new_run_list).each do |recipe_name|
      recipes << Recipe.new(:name => recipe_name)
    end
    save
  end

  def optional_recipes
    self.class.optional_recipes
  end

  private
    def valid_new_runlist(new_runlist)
      (optional_recipes & new_runlist).sort
    end

    def setup_default_recipes
      self.run_list = ["ruby", "ruby::irbrc", "node", "python", "erlang"]
    end
end

class Recipe
  include Mongoid::Document
  field :name
  embedded_in :user, :inverse_of => :recipes
end
