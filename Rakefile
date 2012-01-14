require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'
require 'appraisal'

desc 'Default: run unit tests against all supported versions of ActiveRecord'
task :default => ["appraisal:install"] do |t|
  exec("rake appraisal test")
end

desc 'Test the socialization plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
