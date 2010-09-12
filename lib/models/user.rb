require 'mongoid'

class User
  include Mongoid::Document
  field :name
  field :login
  embeds_many :recipes

  def self.load_user(github_user)
    user = User.first(:conditions => {:login => github_user.login})
    
    if (user.nil?)
      user = User.new(:name => github_user.name, :login => github_user.login)
      user.save
    end

    user
  end

end

class Recipe
  include Mongoid::Document
  field :name
  embedded_in :user, :inverse_of => :recipes

  
end 



