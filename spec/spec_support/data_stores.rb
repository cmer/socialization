require 'mock_redis' if $MOCK_REDIS
require 'redis' unless $MOCK_REDIS

silence_warnings do
  Redis = MockRedis if $MOCK_REDIS # Magic!
end

def use_redis_store
  Socialization.follow_model = Socialization::RedisStores::Follow
  Socialization.mention_model = Socialization::RedisStores::Mention
  Socialization.like_model = Socialization::RedisStores::Like
  setup_model_shortcuts
end

def use_ar_store
  Socialization.follow_model = Socialization::ActiveRecordStores::Follow
  Socialization.mention_model = Socialization::ActiveRecordStores::Mention
  Socialization.like_model = Socialization::ActiveRecordStores::Like
  setup_model_shortcuts
end

def setup_model_shortcuts
  $Follow = Socialization.follow_model
  $Mention = Socialization.mention_model
  $Like = Socialization.like_model
end

def clear_redis
  Socialization.redis.keys(nil).each do |k|
    Socialization.redis.del k
  end
end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.logger.level = Logger::WARN

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :name
  end

  create_table :celebrities do |t|
    t.string :name
  end

  create_table :movies do |t|
    t.string :name
  end

  create_table :comments do |t|
    t.integer :user_id
    t.integer :movie_id
    t.string :body
  end

  create_table :follows do |t|
    t.string  :follower_type
    t.integer :follower_id
    t.string  :followable_type
    t.integer :followable_id
    t.datetime :created_at
  end

  create_table :likes do |t|
    t.string  :liker_type
    t.integer :liker_id
    t.string  :likeable_type
    t.integer :likeable_id
    t.datetime :created_at
  end

  create_table :mentions do |t|
    t.string  :mentioner_type
    t.integer :mentioner_id
    t.string  :mentionable_type
    t.integer :mentionable_id
    t.datetime :created_at
  end

  create_table :im_a_followers do |t|
    t.timestamps null: true
  end

  create_table :im_a_follower_with_counter_caches do |t|
    t.integer :followees_count, default: 0
    t.timestamps null: true
  end

  create_table :im_a_followables do |t|
    t.timestamps null: true
  end

  create_table :im_a_followable_with_counter_caches do |t|
    t.integer :followers_count, default: 0
    t.timestamps null: true
  end

  create_table :im_a_likers do |t|
    t.timestamps null: true
  end

  create_table :im_a_liker_with_counter_caches do |t|
    t.integer :likees_count, default: 0
    t.timestamps null: true
  end

  create_table :im_a_likeables do |t|
    t.timestamps null: true
  end

  create_table :im_a_likeable_with_counter_caches do |t|
    t.integer :likers_count, default: 0
    t.timestamps null: true
  end

  create_table :im_a_mentioners do |t|
    t.timestamps null: true
  end

  create_table :im_a_mentioner_with_counter_caches do |t|
    t.integer :mentionees_count, default: 0
    t.timestamps null: true
  end

  create_table :im_a_mentionables do |t|
    t.timestamps null: true
  end

  create_table :im_a_mentionable_with_counter_caches do |t|
    t.integer :mentioners_count, default: 0
    t.timestamps null: true
  end

  create_table :im_a_mentioner_and_mentionables do |t|
    t.timestamps null: true
  end

  create_table :vanillas do |t|
    t.timestamps null: true
  end
end

class ::Celebrity < ActiveRecord::Base
  acts_as_followable
  acts_as_mentionable
end

class ::User < ActiveRecord::Base
  acts_as_follower
  acts_as_followable
  acts_as_liker
  acts_as_likeable
  acts_as_mentionable

  has_many :comments
end

class ::Comment < ActiveRecord::Base
  acts_as_mentioner
  belongs_to :user
  belongs_to :movie
end

class ::Movie < ActiveRecord::Base
  acts_as_likeable
  has_many :comments
end

# class Follow < Socialization::ActiveRecordStores::Follow; end
# class Like < Socialization::ActiveRecordStores::Like; end
# class Mention < Socialization::ActiveRecordStores::Mention; end

class ::ImAFollower < ActiveRecord::Base
  acts_as_follower
end
class ::ImAFollowerWithCounterCache < ActiveRecord::Base
  acts_as_follower
end
class ::ImAFollowerChild < ImAFollower; end

class ::ImAFollowable < ActiveRecord::Base
  acts_as_followable
end
class ::ImAFollowableWithCounterCache < ActiveRecord::Base
  acts_as_followable
end
class ::ImAFollowableChild < ImAFollowable; end

class ::ImALiker < ActiveRecord::Base
  acts_as_liker
end
class ::ImALikerWithCounterCache < ActiveRecord::Base
  acts_as_liker
end
class ::ImALikerChild < ImALiker; end

class ::ImALikeable < ActiveRecord::Base
  acts_as_likeable
end
class ::ImALikeableWithCounterCache < ActiveRecord::Base
  acts_as_likeable
end
class ::ImALikeableChild < ImALikeable; end

class ::ImAMentioner < ActiveRecord::Base
  acts_as_mentioner
end
class ::ImAMentionerWithCounterCache < ActiveRecord::Base
  acts_as_mentioner
end
class ::ImAMentionerChild < ImAMentioner; end

class ::ImAMentionable < ActiveRecord::Base
  acts_as_mentionable
end
class ::ImAMentionableWithCounterCache < ActiveRecord::Base
  acts_as_mentionable
end
class ::ImAMentionableChild < ImAMentionable; end

class ::ImAMentionerAndMentionable < ActiveRecord::Base
  acts_as_mentioner
  acts_as_mentionable
end

class ::Vanilla < ActiveRecord::Base
end

