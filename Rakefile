require 'rake'
require 'bundler/gem_tasks'
require 'appraisal'

begin
  require 'rspec/core/rake_task'

 	module TempFixForRakeLastComment
  	def last_comment
    	last_description
   	end 
 	end
 	Rake::Application.send :include, TempFixForRakeLastComment

  RSpec::Core::RakeTask.new(:spec)

  desc 'Default: run unit tests against all supported versions of ActiveRecord'
  task :default => ["appraisal:install"] do |t|
    exec("rake appraisal spec")
  end
rescue LoadError
end
