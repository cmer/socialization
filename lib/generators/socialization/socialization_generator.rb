require 'rails/generators'
require 'rails/generators/migration'

class SocializationGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path(File.join('..', '..', '..', 'generators', 'socialization', 'templates'), File.dirname(__FILE__))

  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  def create_migration_file
    copy_file 'model_follow.rb', 'app/models/follow.rb'
    copy_file 'model_like.rb', 'app/models/like.rb'
    migration_template 'migration_follows.rb', 'db/migrate/create_follows.rb'
    sleep 1 # wait a second to have a unique migration timestamp
    migration_template 'migration_likes.rb', 'db/migrate/create_likes.rb'
  end
end