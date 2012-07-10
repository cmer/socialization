# require File.expand_path(File.dirname(__FILE__)) + '/base'

module Socialization
  module RedisStores
    class Like < Socialization::RedisStores::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::Like
      extend Socialization::RedisStores::Mixins::Base

      class << self
        def like!(liker, likeable)
          unless likes?(liker, likeable)
            Socialization.redis.sadd generate_likers_key(liker, likeable), liker.id
            Socialization.redis.sadd generate_likeables_key(liker, likeable), likeable.id

            call_after_create_hooks(liker, likeable)
            liker.touch if [:all, :liker].include?(touch) && liker.respond_to?(:touch)
            likeable.touch if [:all, :likeable].include?(touch) && likeable.respond_to?(:touch)
            true
          else
            false
          end
        end

        def unlike!(liker, likeable)
          if likes?(liker, likeable)
            Socialization.redis.srem generate_likers_key(liker, likeable), liker.id
            Socialization.redis.srem generate_likeables_key(liker, likeable), likeable.id

            call_after_destroy_hooks(liker, likeable)
            liker.touch if [:all, :liker].include?(touch) && liker.respond_to?(:touch)
            likeable.touch if [:all, :likeable].include?(touch) && likeable.respond_to?(:touch)
            true
          else
            false
          end
        end

        def likes?(liker, likeable)
          Socialization.redis.sismember generate_likers_key(liker, likeable), liker.id
        end

        # Returns an ActiveRecord::Relation of all the likers of a certain type that are likeing likeable
        def likers_relation(likeable, klass, opts = {})
          ids = likers(likeable, klass, :pluck => :id)
          klass.where('id IN (?)', ids)
        end

        # Returns all the likers of a certain type that are likeing likeable
        def likers(likeable, klass, opts = {})
          if opts[:pluck]
            Socialization.redis.smembers(generate_likers_key(klass, likeable)).map { |id|
              id.to_i if id.is_integer?
            }
          else
            likers_relation(likeable, klass, opts).all
          end
        end

        # Returns an ActiveRecord::Relation of all the likeables of a certain type that are liked by liker
        def likeables_relation(liker, klass, opts = {})
          ids = likeables(liker, klass, :pluck => :id)
          klass.where('id IN (?)', ids)
        end

        # Returns all the likeables of a certain type that are liked by liker
        def likeables(liker, klass, opts = {})
          if opts[:pluck]
            Socialization.redis.smembers(generate_likeables_key(liker, klass)).map { |id|
              id.to_i if id.is_integer?
            }
          else
            likeables_relation(liker, klass, opts).all
          end
        end

        def touch(what = nil)
          if what.nil?
            @touch || false
          else
            raise ArgumentError unless [:all, :liker, :likeable, false, nil].include?(what)
            @touch = what
          end
        end

        def after_like(method)
          raise ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_create_hook = method
        end

        def after_unlike(method)
          raise ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_destroy_hook = method
        end

      private
        def call_after_create_hooks(liker, likeable)
          self.send(@after_create_hook, liker, likeable) if @after_create_hook
        end

        def call_after_destroy_hooks(liker, likeable)
          self.send(@after_destroy_hook, liker, likeable) if @after_destroy_hook
        end

        def generate_likers_key(liker, likeable)
          generate_actor_key(liker, likeable, :like)
        end

        def generate_likeables_key(liker, likeable)
          generate_victim_key(liker, likeable, :like)
        end
      end # class << self

    end
  end
end
