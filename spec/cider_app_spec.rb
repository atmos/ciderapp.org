require File.dirname(__FILE__) + "/spec_helper"

describe "Ciderapp.org" do
  it "GET / redirects to the github page" do
    response = get "/"
    response.headers['Location'].should eql('http://www.atmos.org/cider')
  end

  it "GET /auth/github redirects to github oauth" do
    response = get "/auth/github"
    uri = Addressable::URI.parse(response.headers["Location"])
    uri.should_not be_nil
    uri.scheme.should eql('https')

    params = uri.query_values
    params['type'].should         == 'web_server'
    params['scope'].should        == 'email,offline_access'
    params['client_id'].should    == true
    params['redirect_uri'].should == 'http://ciderapp.org/auth/github/callback'
  end

  it "GET /latest/run_list responds w/ the JSON required to build out an environment" do
    response = get "/latest"
    data = JSON.parse(response.body)

    data["recipes"].should eql(["homebrew", "rvm", "node", "rails", "sinatra"])
  end

  it "GET /refresh responds w/ the status of generating a new tgz" do
    response = post "/refresh"
    JSON.parse(response.body)["status"].should be_true

    response = post "/refresh"
    JSON.parse(response.body)["status"].should be_true
  end
end
