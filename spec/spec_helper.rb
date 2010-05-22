require 'pp'
Bundler.require(:default, :runtime, :test)

require File.join(File.dirname(__FILE__), '..', 'lib', 'cider_app')

Spec::Runner.configure do |config|
  config.include(Rack::Test::Methods)

  def app
    CiderApp.app
  end
end
