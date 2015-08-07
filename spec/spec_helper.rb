$MOCK_REDIS = true

require 'bundler/setup'
Bundler.setup

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end

$:.push File.expand_path("../lib", __FILE__)
require 'active_record'
require "socialization"
require 'spec_helpers/data_stores'
require 'logger'

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'cache', 'caches'
end
