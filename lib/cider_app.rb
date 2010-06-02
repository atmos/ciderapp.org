require 'yaml'
require 'sinatra_auth_github'

module CiderApp
  def self.app
    @app ||= Rack::Builder.new do
      use Rack::Static, :urls => ["/css", "/img", "/js"], :root => "public"
      run CiderApp::App
    end
  end
end

require File.dirname(__FILE__)+'/cider_app/app'
