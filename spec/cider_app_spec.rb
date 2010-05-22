require File.dirname(__FILE__) + '/spec_helper'

describe "Ciderapp.org" do
  it "GET / redirects to the github page" do
    get '/'
    last_response.headers['Location'].should eql("http://github.com/atmos/cider")
  end

  it "GET /latest responds w/ the JSON required to build out an environment" do
    response = get '/latest'
    data = JSON.parse(response.body)

    data['url'].should eql('http://ciderapp.org/cider.tgz')
    data['recipes'].should eql(['homebrew', 'git', 'rvm', 'node'])
  end
end
