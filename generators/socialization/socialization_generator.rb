class SocializationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.template 'model_follow.rb',  'app/models/follow.rb'
      m.template 'model_like.rb',    'app/models/like.rb'
      m.template 'model_mention.rb', 'app/models/mention.rb'

      m.migration_template 'migration_follows.rb', 'db/migrate',  :migration_file_name => 'create_follows'
      sleep 1  # force unique migration timestamp
      m.migration_template 'migration_likes.rb', 'db/migrate',    :migration_file_name => 'create_likes'
      sleep 1  # force unique migration timestamp
      m.migration_template 'migration_mentions.rb', 'db/migrate', :migration_file_name => 'create_mentions'
    end
  end
end