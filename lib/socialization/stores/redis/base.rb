module Socialization
  module RedisStores
    class Base

      class << self
      protected
        def generate_actor_key(actor, victim, type)
          keys = key_type_to_class_names(type)
          raise ArgumentError.new("`#{keys[1]}` needs to be an acts_as_#{keys[1]} objects, not a class.") if victim.class == Class
          unless actor.nil?
            "#{keys[0].pluralize.capitalize}:#{victim.class}:#{victim.id}:#{actor.class == Class ? actor : actor.class}"
          else
            "#{keys[0].pluralize.capitalize}:#{victim.class}:#{victim.id}"
          end
        end

        def generate_victim_key(actor, victim, type)
          keys = key_type_to_class_names(type)
          raise ArgumentError.new("`#{keys[0]}` needs to be an acts_as_#{keys[0]} objects, not a class.") if actor.class == Class
          unless victim.nil?
            "#{keys[1].pluralize.capitalize}:#{actor.class}:#{actor.id}:#{victim.class == Class ? victim : victim.class}"
          else
            "#{keys[1].pluralize.capitalize}:#{actor.class}:#{actor.id}"
          end
        end

      private
        def key_type_to_class_names(type)
          case type
          when :follow
            ['follower', 'followable']
          when :like
            ['liker', 'likeable']
          when :mention
            ['mentioner', 'mentionable']
          else
            raise NotImplementedError
          end
        end
      end

    end
  end
end