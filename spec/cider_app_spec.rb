require File.dirname(__FILE__) + "/spec_helper"

describe "Ciderapp.org" do
  it "GET / redirects to the github page" do
    response = get "/"
    response.headers['Location'].should eql('http://www.atmos.org/cider')
  end

  it "GET /profile redirects to github oauth" do
    response = get "/profile"

    uri = Addressable::URI.parse(response.headers["Location"])
    uri.should_not be_nil
    uri.scheme.should eql('https')

    params = uri.query_values
    params['type'].should eql('web_server')
    params['scope'].should eql('email,offline_access')
    params['client_id'].should match(/\w{20}/)
    params['redirect_uri'].should eql('http://example.org/auth/github/callback')
  end

  it "GET /latest/run_list responds w/ the JSON required to build out an environment" do
    response = get "/latest"
    data = JSON.parse(response.body)

    data["recipes"].should eql(["homebrew", "homebrew::dbs", "homebrew::misc", "ruby", "ruby::irbrc", "ruby::rails", "ruby::sinatra", "node" ])
  end

  it "GET /refresh responds w/ the status of generating a new tgz" do
    response = post "/refresh"
    JSON.parse(response.body)["status"].should be_true

    response = post "/refresh"
    JSON.parse(response.body)["status"].should be_true
  end
end
