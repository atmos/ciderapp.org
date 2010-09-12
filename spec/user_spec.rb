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

end
