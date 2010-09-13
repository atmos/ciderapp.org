begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  require "rubygems"
  require "bundler"
  Bundler.setup
end

task :default => [:spec]
namespace :db do
  desc "eycloud fail"
  task :migrate do
    system("french deploy")
  end
end

begin
  require 'spec/rake/spectask'
  desc "Run specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = %w(-fs --color)
    t.spec_opts << '--loadby' << 'random'

    #t.rcov_opts << '--exclude' << 'spec,.bundle,.rvm'
    #t.rcov = ENV.has_key?('NO_RCOV') ? ENV['NO_RCOV'] != 'true' : true
    #t.rcov_opts << '--text-summary'
    #t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
  end
rescue LoadError
end
