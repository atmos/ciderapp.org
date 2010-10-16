require File.dirname(__FILE__) + "/spec_helper"

describe "User Recipes" do
  context "if authenticated" do
    let(:user) { User.create(:name => "garrensmith") }

    before(:all) do
      CiderApp::App.class_eval do
        helpers do
          def authenticated?
            return true
          end

          def github_user
            Spec::Mocks::Mock.new('GithubUser', :login => 'garrensmith')
          end
        end
      end
    end

    it "GET /profile should return view with user details" do
      response = get "/profile"
      response.should be_ok
      response.should =~  /<input type="button" id="submit" value="Update"/
    end

    it "PUT /users/:user should update users desired recipes and save" do
      response = put "/profile/#{user.name}/recipes", {"recipes" => "node,ruby"}
      response.should be_redirect

      response = get "/profile/#{user.name}/recipes"
      data = JSON.parse(response.body)

      pp response
      data["recipes"].should eql(["homebrew", "homebrew::dbs", "homebrew::misc", "node", "ruby"])
    end

    it "returns name " do
      response = get "/name"
      pp response

    end
  end
end
