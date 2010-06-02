ENV['RACK_ENV'] ||= 'development'
begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  require "rubygems"
  require "bundler"
  Bundler.setup
end

Bundler.require(:runtime)

require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'cider_app'))

run CiderApp.app

# vim:ft=ruby
