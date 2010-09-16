require 'sinatra/auth/github'
require 'mongoid'
require 'uri'
puts __FILE__
$: << File.dirname(__FILE__) + '/models/'
require "User"


module CiderApp


  class App < Sinatra::Base
    set     :root, File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
    set     :github_options, { :client_id => ENV["GITHUB_CLIENT_ID"], :secret => ENV["GITHUB_CLIENT_SECRET"]}
    set     :views, File.dirname(__FILE__) + '/views'

    enable  :sessions
    enable  :raise_errors
    disable :show_exceptions


    register Sinatra::Auth::Github

    configure  do

      if ENV['MONGOHQ_URL']
        mongo_uri = URI.parse(ENV['MONGOHQ_URL'])

        Mongoid.database = Mongo::Connection.new(mongo_uri.host, mongo_uri.port.to_s).db("ciderapp")
        Mongoid.database.authenticate(mongo_uri.user,mongo_uri.password)
      else
        Mongoid.configure do |config|
          name = "ciderapp"
          host = "localhost"
          config.master = Mongo::Connection.new.db(name)
          config.slaves = [Mongo::Connection.new(host, 27017, :slave_ok => true).db(name)]
          config.persist_in_safe_mode = false
        end
      end
    end


    helpers do
      def silently_run(command)
        system("#{command} >> ./run.log 2>&1")
      end

      def recipe_file
        @recipe_file ||= "cider.tgz"
      end

      def recipes
        [ "homebrew", "homebrew::dbs", "homebrew::misc",
            "ruby", "ruby::irbrc", "node"
        ]
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
        redirect 'http://www.atmos.org/cinderella/intro.html'
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
      { :recipes => recipes}.to_json
    end

    post '/refresh' do
      content_type :json
      refresh_cookbooks
      { :status => $? == 0 }.to_json
    end

    get '/runlists/:login' do
      if authenticated?
        @user = User.load_user(params[:login])
        erb :user_profile
      else
        redirect '/profile'
      end     

    end

    post '/update' do
      begin
        user = User.load_user(github_user.login)
        selected_recipes = params["recipes"].split(',') 

        user.update_recipes(selected_recipes)
        user.save
      "Recipes saved!"
      rescue
        "Oops, failed to save"
      end      
    end

    get '/userrecipe/:user' do
      user = User.first(:conditions => {:name => params[:user]})

      content_type :json
      return {"recipes" => "User not created a recipe"}.to_json if (user.nil?)

      {"recipes" =>  user.recipes.map{ |recipe| recipe.name }}.to_json   
    end
  end
end

