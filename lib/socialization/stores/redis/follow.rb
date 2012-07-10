# require File.expand_path(File.dirname(__FILE__)) + '/base'

module Socialization
  module RedisStores
    class Follow < Socialization::RedisStores::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::Follow
      extend Socialization::RedisStores::Mixins::Base

      class << self
        def follow!(follower, followable)
          unless follows?(follower, followable)
            Socialization.redis.sadd generate_followers_key(follower, followable), follower.id
            Socialization.redis.sadd generate_followables_key(follower, followable), followable.id

            call_after_create_hooks(follower, followable)
            true
          else
            false
          end
        end

        def unfollow!(follower, followable)
          if follows?(follower, followable)
            Socialization.redis.srem generate_followers_key(follower, followable), follower.id
            Socialization.redis.srem generate_followables_key(follower, followable), followable.id

            call_after_destroy_hooks(follower, followable)
            true
          else
            false
          end
        end

        def follows?(follower, followable)
          Socialization.redis.sismember generate_followers_key(follower, followable), follower.id
        end

        # Returns an ActiveRecord::Relation of all the followers of a certain type that are following followable
        def followers_relation(followable, klass, opts = {})
          ids = followers(followable, klass, :pluck => :id)
          klass.where('id IN (?)', ids)
        end

        # Returns all the followers of a certain type that are following followable
        def followers(followable, klass, opts = {})
          if opts[:pluck]
            Socialization.redis.smembers(generate_followers_key(klass, followable)).map { |id|
              id.to_i if id.is_integer?
            }
          else
            followers_relation(followable, klass, opts).all
          end
        end

        # Returns an ActiveRecord::Relation of all the followables of a certain type that are followed by follower
        def followables_relation(follower, klass, opts = {})
          ids = followables(follower, klass, :pluck => :id)
          klass.where('id IN (?)', ids)
        end

        # Returns all the followables of a certain type that are followed by follower
        def followables(follower, klass, opts = {})
          if opts[:pluck]
            Socialization.redis.smembers(generate_followables_key(follower, klass)).map { |id|
              id.to_i if id.is_integer?
            }
          else
            followables_relation(follower, klass, opts).all
          end
        end

      private
        def generate_followers_key(follower, followable)
          generate_actor_key(follower, followable, :follow)
        end

        def generate_followables_key(follower, followable)
          generate_victim_key(follower, followable, :follow)
        end
      end # class << self

    end
  end
end
