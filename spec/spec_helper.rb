require 'pp'
Bundler.require(:default, :runtime, :test)
require 'spec/mocks'

require File.join(File.dirname(__FILE__), '..', 'lib', 'cider_app')

Spec::Runner.configure do |config|
  config.include(Rack::Test::Methods)

  config.before(:each) do
    User.delete_all
  end

  def app
    CiderApp.app
  end
end
