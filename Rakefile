require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

# only load Bionic rake tasks once
unless Rake::Task.task_defined? "bionic:release"
  Dir["#{BIONIC_ROOT}/lib/tasks/**/*.rake"].sort.each { |ext| load ext }
end
# only load Bionic plugin rake tasks once
unless Rake::Task.task_defined? "ts:version"
  Dir["#{BIONIC_ROOT}/vendor/plugins/*/lib/tasks/**/*.rake"].sort.each { |ext| load ext }
end