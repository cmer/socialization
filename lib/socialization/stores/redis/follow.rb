require File.expand_path(File.dirname(__FILE__)) + '/base'

module Socialization
  module RedisStores
    class Follow < Socialization::RedisStores::Base
      class << self
        def follow!(follower, followable)
          unless follows?(follower, followable)
            Socialization.redis.sadd generate_followers_key(follower, followable), follower.id
            Socialization.redis.sadd generate_followables_key(follower, followable), followable.id

            call_after_create_hook(follower, followable)
            follower.touch if [:all, :follower].include?(touch) && follower.respond_to?(:touch)
            followable.touch if [:all, :followable].include?(touch) && followable.respond_to?(:touch)
            true
          else
            false
          end
        end

        def unfollow!(follower, followable)
          if follows?(follower, followable)
            Socialization.redis.srem generate_followers_key(follower, followable), follower.id
            Socialization.redis.srem generate_followables_key(follower, followable), followable.id

            call_after_destroy_hook(follower, followable)
            follower.touch if [:all, :follower].include?(touch) && follower.respond_to?(:touch)
            followable.touch if [:all, :followable].include?(touch) && followable.respond_to?(:touch)
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

        def touch(what = nil)
          if what.nil?
            @touch || false
          else
            raise ArgumentError unless [:all, :follower, :followable, false, nil].include?(what)
            @touch = what
          end
        end

        def after_follow(method)
          raise ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_create_hook = method
        end

        def after_unfollow(method)
          raise ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_destroy_hook = method
        end

      private
        def call_after_create_hook(follower, followable)
          self.send(@after_create_hook, follower, followable) if @after_create_hook
        end

        def call_after_destroy_hook(follower, followable)
          self.send(@after_destroy_hook, follower, followable) if @after_destroy_hook
        end

        def generate_followers_key(follower, followable)
          raise ArgumentError.new("`followable` needs to be an acts_as_followable objecs, not a class.") if followable.class == Class
          follower_class = if follower.class == Class
            follower
          else
            follower.class
          end

          "Followers:#{followable.class}:#{followable.id}:#{follower_class}"
        end

        def generate_followables_key(follower, followable)
          raise ArgumentError.new("`follower` needs to be an acts_as_follower object, not a class.") if follower.class == Class
          followable_class = if followable.class == Class
            followable
          else
            followable.class
          end

          "Followables:#{follower.class}:#{follower.id}:#{followable_class}"
        end
      end # class << self

    end
  end
end
