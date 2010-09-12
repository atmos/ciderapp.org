require 'pp'
Bundler.require(:default, :runtime, :test)

require File.join(File.dirname(__FILE__), '..', 'lib', 'cider_app')

Spec::Runner.configure do |config|
  config.include(Rack::Test::Methods)

  config.after :suite do
    Mongoid.master.collections.select do |collection|
      collection.name !~ /system/
    end.each(&:drop)
  end
  

  def app
    CiderApp.app
  end
end
