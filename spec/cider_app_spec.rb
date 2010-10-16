require File.dirname(__FILE__) + "/spec_helper"

describe "Ciderapp.org" do
  it "GET / redirects to the github page" do
    response = get "/"
    response.should =~ /profile/
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

    data["recipes"].should eql(["homebrew", "homebrew::dbs", "homebrew::misc", "ruby", "ruby::irbrc", "node", "python"])
  end

  it "GET /refresh responds w/ the status of generating a new tgz" do
    response = post "/refresh"
    JSON.parse(response.body)["status"].should be_true

    response = post "/refresh"
    JSON.parse(response.body)["status"].should be_true
  end

  it "GET /solo_rb responds w/ the latest solo.rb file" do
    response = get "/solo.rb"
    response.status.should eql(200)
    response['Content-Type'].should eql('text/plain;charset=utf-8')
  end
end
