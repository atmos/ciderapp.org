require 'sinatra/auth/github'

module CiderApp
  class MisconfiguredOauthTokens < StandardError; end


  class App < Sinatra::Base
    set     :root, File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
    set     :github_options, { :client_id => ENV["GITHUB_CLIENT_ID"], :secret => ENV["GITHUB_CLIENT_SECRET"] }

    enable  :sessions
    enable  :raise_errors
    disable :show_exceptions

    register Sinatra::Auth::Github

    helpers do
      def silently_run(command)
        system("#{command} >> ./run.log 2>&1")
      end

      def recipe_file
        @recipe_file ||= "cider.tgz"
      end

      def solo_rb
        @solo_rb ||= File.read(File.dirname(__FILE__) + "/solo.rb.txt")
      end

      def refresh_cookbooks
        Dir.chdir("./tmp") do
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
            silently_run("tar czf ../#{recipe_file} --exclude certificates --exclude config --exclude .git --exclude roles --exclude site-cookbooks .")
          end
        end
      end
    end

    get '/logout' do
      logout!
      redirect '/'
    end

    get '/' do
      if authenticated?
        redirect '/profile'
      else
        redirect 'http://www.atmos.org/cider'
      end
    end

    get '/profile' do
      begin
        authenticate!
        "<p>Your OAuth access token: #{github_user.token}</p><p>Your extended profile data:\n#{github_user.inspect}</p>"
      rescue OAuth2::HTTPError
        %(<p>Outdated ?code=#{params[:code]}:</p><p>#{$!}</p><p><a href="/auth/github">Retry</a></p>)
      end
    end

    get '/cider.tgz' do
      refresh_cookbooks unless File.exists?("./tmp/#{recipe_file}")
      send_file("./tmp/#{recipe_file}")
    end

    get '/solo.rb' do
      content_type 'text/plain', :charset => 'utf-8'
      solo_rb
    end

    get '/latest' do
      content_type :json
      { :recipes =>
          [ "homebrew", "homebrew::dbs", "homebrew::misc",
            "ruby", "ruby::irbrc", "node"
          ]
      }.to_json
    end

    post '/refresh' do
      content_type :json
      refresh_cookbooks
      { :status => $? == 0 }.to_json
    end
  end
end
