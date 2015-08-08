$MOCK_REDIS = true

require 'bundler/setup'
Bundler.setup

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

$:.push File.expand_path("../lib", __FILE__)
require 'active_record'
require "socialization"
require 'spec_support/data_stores'
require 'spec_support/matchers'
require 'logger'

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'cache', 'caches'
end
