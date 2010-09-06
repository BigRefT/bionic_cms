require 'rubygems'
require 'rake'
require 'rcov'
require 'spec/rake/spectask'

require 'lib/lockdown.rb'
task :default => 'rcov'

desc "Flog your code for Justice!"
task :flog do
    sh('flog lib/**/*.rb')
end

desc "Run all specs and rcov in a non-sucky way"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_opts = IO.readlines("spec/spec.opts").map {|l| l.chomp.split " "}.flatten
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = IO.readlines("spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "lockdown"
    gemspec.version = Lockdown.version
    gemspec.rubyforge_project = "lockdown"
    gemspec.summary = "Authorization system for Rails 2.x"
    gemspec.description = "Restrict access to your controller actions.  Supports basic model level restrictions as well"
    gemspec.email = "andy@stonean.com"
    gemspec.homepage = "http://stonean.com/wiki/lockdown"
    gemspec.authors = ["Andrew Stone"]
    gemspec.add_development_dependency('rspec')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
