require File.dirname(__FILE__) + "/spec_helper"


describe "Creating custom recipes" do

  context "GET /runlists/login" do
    it "should check if user is authenticated and redirect if not" do

      warden = mock()
      warden.should_receive(:authenticated?).and_return(false)    

      response = get "/runlists/garrensmith"
      response.headers["location"] =~ /profile/

    end

    it "should return create a user with default settings if user does not exist" do
      pending
    end

    it "should return view with options to select" do
      pending
    end

  end

end
