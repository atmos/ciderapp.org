require File.dirname(__FILE__) + "/spec_helper"

$: << File.dirname(__FILE__) + '/../lib/cider_app/models/'
require "user"


describe "User model" do

  context "loading a user" do
    it "Should create new user if does not exist" do
      github_user_mock = mock
      github_user_mock.should_receive(:login).twice.and_return("rambo")
      github_user_mock.should_receive(:name).and_return("John Rambo")

      User.first(:conditions => {:login => "rambo"}).should be_nil

      User.load_user(github_user_mock)
      
      User.first(:conditions => {:login => "rambo"}).name .should == "John Rambo"

    end

    it "Should load user from db if exists" do
      github_user_mock = mock
      github_user_mock.should_receive(:login).and_return("eVedder")      
      User.new(:name => "Eddie Vedder",:login => "eVedder").save

      user = User.load_user(github_user_mock)
      
      user.name.should == "Eddie Vedder"
    end
  end

end
