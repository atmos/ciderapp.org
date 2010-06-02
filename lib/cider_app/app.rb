module CiderApp
  class MisconfiguredOauthTokens < StandardError; end


  class App < Sinatra::Base
    set     :root, File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
    set     :config, YAML.load_file(File.join(root, 'config', 'oauth2.yml'))
    set     :github_options, { :client_id => config['client_id'], :secret => config['secret'] }

    enable  :sessions
    enable  :raise_errors
    disable :show_exceptions

    register Sinatra::Auth::Github

    helpers do
      def silently_run(command)
        system("mkdir -p #{options.root}/log")
        system("#{command} >> #{options.root}/log/run.log 2>&1")
      end

      def recipe_file
        @recipe_file ||= "#{options.root}/public/cider.tgz"
      end
    end

    get '/profile' do
      authenticate!
      redirect '/'
    end

    get '/logout' do
      logout!
      redirect '/'
    end

    get '/' do
      if authenticated?
        "<p>Your OAuth access token: #{github_user.token}</p><p>Your extended profile data:\n#{github_user.inspect}</p>"
      else
        redirect 'http://www.atmos.org/cider'
      end
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
            silently_run("ls -l")
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
  end
end
