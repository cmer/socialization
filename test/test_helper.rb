$MOCK_REDIS = true

require 'rubygems'
require 'active_record'
require 'shoulda'
require 'test/unit'
require 'logger'
require 'mock_redis' if $MOCK_REDIS
require 'redis' unless $MOCK_REDIS
require 'mocha' # mocha always needs to be loaded last! http://stackoverflow.com/questions/3118866/mocha-mock-carries-to-another-test/4375296#4375296
# require 'pry'

$:.push File.expand_path("../lib", __FILE__)
require "socialization"

silence_warnings do
  Redis = MockRedis if $MOCK_REDIS # Magic!
end

module Test::Unit::Assertions
  def assert_true(object, message="")
    assert_equal(true, object, message)
  end

  def assert_false(object, message="")
    assert_equal(false, object, message)
  end

  def assert_array_similarity(expected, actual, message=nil)
    full_message = build_message(message, "<?> expected but was\n<?>.\n", expected, actual)
    assert_block(full_message) { (expected.size ==  actual.size) && (expected - actual == []) }
  end

  def assert_empty(obj, msg = nil)
    msg = "Expected #{obj.inspect} to be empty" unless msg
    assert_respond_to obj, :empty?
    assert obj.empty?, msg
  end

  def assert_method_public(obj, method, msg = nil)
    msg = "Expected method #{obj}.#{method} to be public."
    method = if RUBY_VERSION.match(/^1\.8/)
      method.to_s
    else
      method.to_s.to_sym
    end

    assert obj.public_methods.include?(method), msg
  end
end

class Test::Unit::TestCase
  def setup
    use_ar_store
  end

  def teardown
    clear_redis
  end
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

ActiveRecord::Base.configurations = {'sqlite3' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection('sqlite3')

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
    t.timestamps
  end

  create_table :im_a_followables do |t|
    t.timestamps
  end

  create_table :im_a_followable_with_counter_caches do |t|
    t.integer :followers_count, default: 0
    t.timestamps
  end

  create_table :im_a_likers do |t|
    t.timestamps
  end

  create_table :im_a_likeables do |t|
    t.timestamps
  end

  create_table :im_a_likeable_with_counter_caches do |t|
    t.integer :likers_count, default: 0
    t.timestamps
  end

  create_table :im_a_mentioners do |t|
    t.timestamps
  end

  create_table :im_a_mentionables do |t|
    t.timestamps
  end

  create_table :im_a_mentioner_and_mentionables do |t|
    t.timestamps
  end

  create_table :vanillas do |t|
    t.timestamps
  end
end

class Celebrity < ActiveRecord::Base
  acts_as_followable
  acts_as_mentionable
end

class User < ActiveRecord::Base
  acts_as_follower
  acts_as_followable
  acts_as_liker
  acts_as_likeable
  acts_as_mentionable

  has_many :comments
end

class Comment < ActiveRecord::Base
  acts_as_mentioner
  belongs_to :user
  belongs_to :movie
end

class Movie < ActiveRecord::Base
  acts_as_likeable
  has_many :comments
end

# class Follow < Socialization::ActiveRecordStores::Follow; end
# class Like < Socialization::ActiveRecordStores::Like; end
# class Mention < Socialization::ActiveRecordStores::Mention; end

class ImAFollower < ActiveRecord::Base
  acts_as_follower
end
class ImAFollowerChild < ImAFollower; end

class ImAFollowable < ActiveRecord::Base
  acts_as_followable
end
class ImAFollowableWithCounterCache < ActiveRecord::Base
  acts_as_followable
end
class ImAFollowableChild < ImAFollowable; end

class ImALiker < ActiveRecord::Base
  acts_as_liker
end
class ImALikerChild < ImALiker; end

class ImALikeable < ActiveRecord::Base
  acts_as_likeable
end
class ImALikeableWithCounterCache < ActiveRecord::Base
  acts_as_likeable
end
class ImALikeableChild < ImALikeable; end

class ImAMentioner < ActiveRecord::Base
  acts_as_mentioner
end
class ImAMentionerChild < ImAMentioner; end

class ImAMentionable < ActiveRecord::Base
  acts_as_mentionable
end
class ImAMentionableChild < ImAMentionable; end

class ImAMentionerAndMentionable < ActiveRecord::Base
  acts_as_mentioner
  acts_as_mentionable
end

class Vanilla < ActiveRecord::Base
end
