# require File.expand_path(File.dirname(__FILE__)) + '/base'

module Socialization
  module RedisStores
    class Mention < Socialization::RedisStores::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::Mention
      extend Socialization::RedisStores::Mixins::Base

      class << self
        def mention!(mentioner, mentionable)
          unless mentions?(mentioner, mentionable)
            Socialization.redis.sadd generate_mentioners_key(mentioner, mentionable), mentioner.id
            Socialization.redis.sadd generate_mentionables_key(mentioner, mentionable), mentionable.id

            call_after_create_hooks(mentioner, mentionable)
            true
          else
            false
          end
        end

        def unmention!(mentioner, mentionable)
          if mentions?(mentioner, mentionable)
            Socialization.redis.srem generate_mentioners_key(mentioner, mentionable), mentioner.id
            Socialization.redis.srem generate_mentionables_key(mentioner, mentionable), mentionable.id

            call_after_destroy_hooks(mentioner, mentionable)
            true
          else
            false
          end
        end

        def mentions?(mentioner, mentionable)
          Socialization.redis.sismember generate_mentioners_key(mentioner, mentionable), mentioner.id
        end

        # Returns an ActiveRecord::Relation of all the mentioners of a certain type that are mentioning mentionable
        def mentioners_relation(mentionable, klass, opts = {})
          ids = mentioners(mentionable, klass, :pluck => :id)
          klass.where('id IN (?)', ids)
        end

        # Returns all the mentioners of a certain type that are mentioning mentionable
        def mentioners(mentionable, klass, opts = {})
          if opts[:pluck]
            Socialization.redis.smembers(generate_mentioners_key(klass, mentionable)).map { |id|
              id.to_i if id.is_integer?
            }
          else
            mentioners_relation(mentionable, klass, opts).all
          end
        end

        # Returns an ActiveRecord::Relation of all the mentionables of a certain type that are mentioned by mentioner
        def mentionables_relation(mentioner, klass, opts = {})
          ids = mentionables(mentioner, klass, :pluck => :id)
          klass.where('id IN (?)', ids)
        end

        # Returns all the mentionables of a certain type that are mentioned by mentioner
        def mentionables(mentioner, klass, opts = {})
          if opts[:pluck]
            Socialization.redis.smembers(generate_mentionables_key(mentioner, klass)).map { |id|
              id.to_i if id.is_integer?
            }
          else
            mentionables_relation(mentioner, klass, opts).all
          end
        end

      private
        def generate_mentioners_key(mentioner, mentionable)
          generate_actor_key(mentioner, mentionable, :mention)
        end

        def generate_mentionables_key(mentioner, mentionable)
          generate_victim_key(mentioner, mentionable, :mention)
        end
      end # class << self

    end
  end
end
