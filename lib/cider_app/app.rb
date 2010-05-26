require 'tmpdir'
require 'fileutils'

module CiderApp
  class App < Sinatra::Base
    set     :root, File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
    enable  :raise_errors
    disable :show_exceptions

    helpers do
      def silently_run(command)
        system("#{command} >/dev/null 2>&1")
      end

      def recipe_file
        @recipe_file ||= "#{options.root}/public/cider.tgz"
      end
    end

    get '/' do
      redirect("http://www.atmos.org/cider")
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
  end
end
