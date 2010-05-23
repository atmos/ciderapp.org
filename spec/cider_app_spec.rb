require File.dirname(__FILE__) + "/spec_helper"

describe "Ciderapp.org" do
  it "GET / redirects to the github page" do
    get "/"
    last_response.headers["Location"].should eql("http://atmos.github.com/cider")
  end

  it "GET /latest/run_list responds w/ the JSON required to build out an environment" do
    response = get "/latest"
    data = JSON.parse(response.body)

    data["recipes"].should eql(["homebrew", "rvm", "node"])
  end

  it "GET /refresh responds w/ the status of generating a new tgz" do
    response = get "/refresh"
    JSON.parse(response.body)["status"].should be_true

    response = get "/refresh"
    JSON.parse(response.body)["status"].should be_true
  end
end
