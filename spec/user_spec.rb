require File.dirname(__FILE__) + "/spec_helper"

$: << File.dirname(__FILE__) + '/../lib/cider_app/models/'
require "user"


describe "User model" do

  context "loading a user" do
    it "Should create new user if does not exist" do

      User.first(:conditions => {:name => "rambo"}).should be_nil

      User.load_user("rambo")
      
      User.first(:conditions => {:name => "rambo"}).name.should == "rambo"

    end

    it "Should load user from db if exists" do
      User.new(:name => "eVedder").save

      user = User.load_user("eVedder")
      
      user.name.should == "eVedder"
    end
  end

  context "Updating recipes" do
    it "should delete previous recipes and create new list" do
      user = User.new(:name => "Jimmy")
      
      user.recipes << Recipe.new(:name => "node")
      user.save

      user.update_recipes(["ruby","mongodb"])
      user.save      
      
      user.recipes.count.should == 2
      user.recipes[0].name.should == "ruby"
    end
  end

end
