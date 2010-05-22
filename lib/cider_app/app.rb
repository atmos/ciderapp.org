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
    end

    get '/' do
      redirect("http://github.com/atmos/cider")
    end

    get '/latest/recipes' do
      { :data => { :recipes => [ :homebrew, :git, :rvm, :node ] } }.to_json
    end

    get '/latest/run_list' do
      { :data => { :url => "http://ciderapp.org/cider.tgz" } }.to_json
    end

    get '/refresh' do
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
        silently_run("tar czf #{options.root}/public/cider.tgz smeagol")
      end
      { :status => $? == 0 }.to_json
    end
  end
end
