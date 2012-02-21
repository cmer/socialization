require 'rubygems'
require 'active_record'
require 'mocha'
require 'shoulda'
require 'test/unit'
require 'logger'

$:.push File.expand_path("../lib", __FILE__)
require "socialization"

ActiveRecord::Base.configurations = {'sqlite3' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection('sqlite3')

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.logger.level = Logger::WARN

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

  create_table :im_a_followers do |t|
    t.timestamps
  end

  create_table :im_a_followables do |t|
    t.timestamps
  end

  create_table :im_a_likers do |t|
    t.timestamps
  end

  create_table :im_a_likeables do |t|
    t.timestamps
  end

  create_table :vanillas do |t|
    t.timestamps
  end
end

class Celebrity < ActiveRecord::Base
  acts_as_followable
end

class User < ActiveRecord::Base
  acts_as_follower
  acts_as_followable
  acts_as_liker
  acts_as_likeable
end

class Movie < ActiveRecord::Base
  acts_as_likeable
end

class Follow < ActiveRecord::Base
  acts_as_follow_store
end

class Like < ActiveRecord::Base
  acts_as_like_store
end

class ImAFollower < ActiveRecord::Base
  acts_as_follower
end

class ImAFollowable < ActiveRecord::Base
  acts_as_followable
end

class ImALiker < ActiveRecord::Base
  acts_as_liker
end

class ImALikeable < ActiveRecord::Base
  acts_as_likeable
end

class Vanilla < ActiveRecord::Base
end
