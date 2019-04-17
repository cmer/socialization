module Socialization
  module RedisStores
    class Base

      class << self
      protected
        def actors(subject, klass, options = {})
          if options[:pluck]
            Socialization.redis.smembers(generate_forward_key(subject)).inject([]) do |result, element|
              result << element.match(/\:(\d+)$/)[1] if element.match(/^#{klass}\:/)
              result
            end
          else
            actors_relation(subject, klass, options).to_a
          end
        end

        def actors_relation(subject, klass, options = {})
          ids = actors(subject, klass, :pluck => :id)
          klass.where("#{klass.table_name}.id IN (?)", ids)
        end

        def subjects_relation(actor, klass, options = {})
          ids = subjects(actor, klass, :pluck => :id)
          klass.where("#{klass.table_name}.id IN (?)", ids)
        end
        alias victims_relation subjects_relation

        def subjects(actor, klass, options = {})
          if options[:pluck]
            Socialization.redis.smembers(generate_backward_key(actor)).inject([]) do |result, element|
              result << element.match(/\:(\d+)$/)[1] if element.match(/^#{klass}\:/)
              result
            end
          else
            subjects_relation(actor, klass, options).to_a
          end
        end
        alias victims subjects

        def relation!(actor, subject, options = {})
          unless options[:skip_check] || relation?(actor, subject)
            Socialization.redis.sadd generate_forward_key(subject), generate_redis_value(actor)
            Socialization.redis.sadd generate_backward_key(actor), generate_redis_value(subject)
            call_after_create_hooks(actor, subject)
            true
          else
            false
          end
        end

        def unrelation!(actor, subject, options = {})
          if options[:skip_check] || relation?(actor, subject)
            Socialization.redis.srem generate_forward_key(subject), generate_redis_value(actor)
            Socialization.redis.srem generate_backward_key(actor), generate_redis_value(subject)
            call_after_destroy_hooks(actor, subject)
            true
          else
            false
          end
        end

        def relation?(actor, subject)
          Socialization.redis.sismember generate_forward_key(subject), generate_redis_value(actor)
        end

        def remove_actor_relations(subject)
          forward_key = generate_forward_key(subject)
          actors = Socialization.redis.smembers forward_key
          Socialization.redis.del forward_key
          actors.each do |actor|
            Socialization.redis.srem generate_backward_key(actor), generate_redis_value(subject)
          end
          true
        end

        def remove_subject_relations(actor)
          backward_key = generate_backward_key(actor)
          subjects = Socialization.redis.smembers backward_key
          Socialization.redis.del backward_key
          subjects.each do |subject|
            Socialization.redis.srem generate_forward_key(subject), generate_redis_value(actor)
          end
          true
        end
        alias remove_victim_relations remove_subject_relations


      private
        def key_type_to_type_names(klass)
          if klass.name.match(/Follow$/)
            ['follower', 'followable']
          elsif klass.name.match(/Like$/)
            ['liker', 'likeable']
          elsif klass.name.match(/Mention$/)
            ['mentioner', 'mentionable']
          else
            raise Socialization::ArgumentError.new("Can't find matching type for #{klass}.")
          end
        end

        def generate_forward_key(subject)
          keys = key_type_to_type_names(self)
          if subject.is_a?(String)
            "#{keys[0].pluralize.capitalize}:#{subject}"
          else
            "#{keys[0].pluralize.capitalize}:#{subject.class}:#{subject.id}"
          end
        end

        def generate_backward_key(actor)
          keys = key_type_to_type_names(self)
          if actor.is_a?(String)
            "#{keys[1].pluralize.capitalize}:#{actor}"
          else
            "#{keys[1].pluralize.capitalize}:#{actor.class}:#{actor.id}"
          end
        end

        def generate_redis_value(obj)
          "#{obj.class.name}:#{obj.id}"
        end

      end # class << self

    end # Base
  end # RedisStores
end # Socialization