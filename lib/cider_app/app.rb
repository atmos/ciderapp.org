module CiderApp
  class App < Sinatra::Base
    get '/' do
      redirect("http://github.com/atmos/cider")
    end

    get '/latest' do
      {
        "url"  => "http://ciderapp.org/cider.tgz",
        "recipes" => [ "homebrew", "git", "rvm", "node" ]
      }.to_json
    end
  end
end
