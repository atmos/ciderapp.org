require 'uri'
require 'yaml'
require 'mongoid'
require 'fileutils'
require 'sinatra/auth/github'

module CiderApp
  def self.app
    @app ||= Rack::Builder.new do
      use Rack::Static, :urls => ["/css", "/img", "/js"], :root => "public"
      run CiderApp::App
    end
  end

  def self.oauth_tokens
    { :client_id => ENV["GITHUB_CLIENT_ID"], :secret => ENV["GITHUB_CLIENT_SECRET"]}
  end
end

require File.dirname(__FILE__)+'/cider_app/app'
require File.dirname(__FILE__)+'/cider_app/models/user'
