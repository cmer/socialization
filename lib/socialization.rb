%w(
  lib/*.rb
  stores/mixins/base.rb
  stores/mixins/**/*.rb
  stores/active_record/mixins/base.rb
  stores/active_record/mixins/**/*.rb
  stores/redis/mixins/base.rb
  stores/redis/mixins/**/*.rb
  stores/active_record/**/*.rb
  stores/redis/base.rb
  stores/redis/**/*.rb
  actors/**/*.rb
  victims/**/*.rb
  helpers/**/*.rb
  config/**/*.rb
).each do |path|
  Dir["#{File.dirname(__FILE__)}/socialization/#{path}"].each { |f| require(f) }
end

ActiveRecord::Base.send :include, Socialization::ActsAsHelpers