require 'sinatra/auth/github'
require 'mongoid'
require 'uri'

module CiderApp
  class App < Sinatra::Base
    set     :root, File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
    set     :github_options, CiderApp.oauth_tokens
    set     :views, File.dirname(__FILE__) + '/views'

    enable  :sessions
    enable  :raise_errors
    enable  :method_override
    disable :show_exceptions

    register Sinatra::Auth::Github

    configure  do
      mongo_url = ENV['MONGOHQ_URL'] || 'localhost:27017'
      mongo_uri = URI.parse(mongo_url)

      Mongoid.database = Mongo::Connection.new(mongo_uri.host, mongo_uri.port.to_s).db("ciderapp")
      if mongo_uri.user && mong_uri.password
        Mongoid.database.authenticate(mongo_uri.user,mongo_uri.password)
      end
    end

    helpers do
      def silently_run(command)
        system("#{command} >> ./run.log 2>&1")
      end

      def recipe_file
        @recipe_file ||= "cider.tgz"
      end

      def default_recipes
        [ "homebrew", "homebrew::dbs", "homebrew::misc",
          "ruby", "ruby::irbrc", "node", "python"
        ]
      end

      def optional_recipes
        [ "ruby", "ruby::irbrc", "node", "python", "erlang", "oh-my-zsh" ]
      end

      def user_recipes
        pp user.recipes.map { |recipe| recipe.name }
        [ "homebrew", "homebrew::dbs", "homebrew::misc" ] +
          user.recipes.map { |recipe| recipe.name }
      end

      def solo_rb
        @solo_rb ||= File.read(File.dirname(__FILE__) + "/solo.rb.txt")
      end

      def user
        @user ||= User.get(github_user.login)
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

    get '/' do
      erb :home
    end

    get '/profile' do
      if authenticated?
        erb :profile
      else
        authenticate!
      end
    end

    get '/profile/:user/recipes' do
      if user
        content_type :json
        {"recipes" =>  user_recipes}.to_json
      else
        not_found
      end
    end

    put '/profile/:user/recipes' do
      if authenticated?
        selected_recipes = params['recipes'].split(',')
        user.run_list    = selected_recipes
      end
      redirect '/profile'
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
      { :recipes => default_recipes}.to_json
    end

    post '/refresh' do
      content_type :json
      refresh_cookbooks
      { :status => $? == 0 }.to_json
    end

    get '/logout' do
      logout!
      redirect '/'
    end
  end
end
