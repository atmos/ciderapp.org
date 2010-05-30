require 'tmpdir'
require 'fileutils'
require 'oauth2'

module CiderApp
  class MisconfiguredOauthTokens < StandardError; end

  class App < Sinatra::Base
    set     :root, File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
    enable  :raise_errors
    disable :show_exceptions

    helpers do
      def oauth_client
        OAuth2::Client.new(ENV['CIDER_GITHUB_SECRET'],
                           ENV['CIDER_GITHUB_CLIENT_ID'],
                           :site              => 'https://github.com',
                           :authorize_path    => '/login/oauth/authorize',
                           :access_token_path => '/login/oauth/access_token')
      end

      def redirect_uri
        'http://ciderapp.org/auth/github/callback'
      end

      def silently_run(command)
        system("#{command} >/dev/null 2>&1")
      end

      def recipe_file
        @recipe_file ||= "#{options.root}/public/cider.tgz"
      end
    end

    get '/' do
      redirect 'http://www.atmos.org/cider'
    end

    get '/latest' do
      content_type :json
      { :recipes => [ :homebrew, :rvm, :node, :rails, :sinatra ]  }.to_json
    end

    post '/refresh' do
      content_type :json

      Dir.chdir(Dir.tmpdir) do
        FileUtils.mkdir_p "#{options.root}/public"
        if File.directory?("smeagol")
          Dir.chdir("smeagol") do
            silently_run("git checkout master")
            silently_run("git reset --hard origin/master")
            silently_run("git pull")
          end
        else
          silently_run("git clone git://github.com/atmos/smeagol.git")
        end
        Dir.chdir("smeagol") do
          silently_run("tar czf #{recipe_file} --exclude certificates --exclude config --exclude .git --exclude roles --exclude site-cookbooks .")
        end
      end
      { :status => $? == 0 }.to_json
    end

    get '/auth/github' do
      url = oauth_client.web_server.authorize_url(
        :scope        => 'email,offline_access',
        :redirect_uri => redirect_uri
      )
      redirect url
    end

    get '/auth/github/callback' do
      begin
        access_token = oauth_client.web_server.get_access_token(params[:code], :redirect_uri => redirect_uri)
        user = JSON.parse(access_token.get('/api/v2/json/user/show'))
                      "<p>Your OAuth access token: #{access_token.token}</p><p>Your extended profile data:\n#{user.inspect}</p>"
      rescue OAuth2::HTTPError
        %(<p>Outdated ?code=#{params[:code]}:</p><p>#{$!}</p><p><a href="/auth/github">Retry</a></p>)
      end
    end
  end
end

if ENV['CIDER_GITHUB_CLIENT_ID'].nil? || ENV['CIDER_GITHUB_SECRET'].nil?
  raise CiderApp::MisconfiguredOauthTokens, <<-EOS
Your environment is misconfigured,
  GITHUB_CIDER_SECRET=#{ENV['CIDER_GITHUB_SECRET'].inspect}
  GITHUB_CIDER_CLIENT_ID=#{ENV['CIDER_GITHUB_CLIENT_ID'].inspect}
EOS
end
