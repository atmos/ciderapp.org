require 'json'
require 'sinatra/base'

module CiderApp
  def self.app
    @app ||= Rack::Builder.new do
      run CiderApp::App
    end
  end
end

require File.dirname(__FILE__)+'/cider_app/app'
