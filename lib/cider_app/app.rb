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
      mongo_url = ENV['MONGOHQ_URL'] || 'mongodb://localhost:27017/ciderapp'
      mongo_uri = URI.parse(mongo_url)

      Mongoid.database = Mongo::Connection.new(mongo_uri.host, mongo_uri.port.to_s).db(mongo_uri.path.gsub('/', ''))
      if mongo_uri.user && mongo_uri.password
        Mongoid.database.authenticate(mongo_uri.user,mongo_uri.password)
      end
    end

    helpers do
      def silently_run(command)
        system("#{command} >> ./run.log 2>&1")
      end

      def recipe_file
        @recipe_file ||= File.expand_path(File.dirname(__FILE__) + "/../../cider.tgz")
      end

      def solo_rb
        @solo_rb ||= File.read(File.dirname(__FILE__) + "/solo.rb.txt")
      end

      def user
        @user ||= User.get(github_user.login)
      end
    end

    get '/' do
      if authenticated?
        redirect "/profile"
      else
        erb :home
      end
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
        {"recipes" =>  user.run_list}.to_json
      else
        not_found
      end
    end

    put '/profile/:user/recipes' do
      if authenticated?
        user.run_list = params.keys
      end
      redirect '/profile'
    end

    get '/cider.tgz' do
      send_file(recipe_file)
    end

    get '/solo.rb' do
      content_type 'text/plain', :charset => 'utf-8'
      solo_rb
    end

    get '/latest' do
      content_type :json
      { :recipes => User.default_recipes}.to_json
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
