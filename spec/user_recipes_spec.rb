require File.dirname(__FILE__) + "/spec_helper"
require File.join(File.dirname(__FILE__), '..', 'lib', 'cider_app')

class Github_user_mock
  def login
    "garrensmith"
  end
end

describe "User Recipes" do

  context "if authenticated" do
    before(:all) do
      CiderApp::App.class_eval do
        helpers do
          def authenticated?
            return true
          end

          def github_user
            Github_user_mock.new
          end
        end
      end
    end

    it "GET /runlists/login should return view with user details" do

      response = get "/runlists/garrensmith"
      response.should be_ok
    end

    it "GET /runlists/login should display update button if user same as recipe user" do
      response = get "/runlists/garrensmith"
      response.should =~  /<input type="button" id="submit" value="Update"/

    end

    it "GET /runlists/login  should not display submit button if user not the same as recipe user" do
      response = get "/runlists/jimmy"
      response.should_not =~  /<input type="button" id="submit" value="Update"/
    end


    it "Post /update should update users details and save" do
      User.new(:name => "garrensmith").save

      response = post "/update",{"recipes" => "node,ruby"}
      response.should be_ok
      response.body.should =~ /saved/
    end
  end

end
