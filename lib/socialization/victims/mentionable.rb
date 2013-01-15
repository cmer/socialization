module ActiveRecord
  class Base
    def is_mentionable?
      false
    end
    alias mentionable? is_mentionable?
  end
end

module Socialization
  module Mentionable
    extend ActiveSupport::Concern

    included do
      after_destroy { Socialization.mention_model.remove_mentioners(self) }

      # Specifies if self can be mentioned.
      #
      # @return [Boolean]
      def is_mentionable?
        true
      end
      alias mentionable? is_mentionable?

      # Specifies if self is mentioned by a {Mentioner} object.
      #
      # @return [Boolean]
      def mentioned_by?(mentioner)
        raise Socialization::ArgumentError, "#{mentioner} is not mentioner!"  unless mentioner.respond_to?(:is_mentioner?) && mentioner.is_mentioner?
        Socialization.mention_model.mentions?(mentioner, self)
      end

      # Returns an array of {Mentioner}s mentioning self.
      #
      # @param [Class] klass the {Mentioner} class to be included. e.g. `User`
      # @return [Array<Mentioner, Numeric>] An array of Mentioner objects or IDs
      def mentioners(klass, opts = {})
        Socialization.mention_model.mentioners(self, klass, opts)
      end

      # Returns a scope of the {Mentioner}s mentioning self.
      #
      # @param [Class] klass the {Mentioner} class to be included in the scope. e.g. `User`
      # @return ActiveRecord::Relation
      def mentioners_relation(klass, opts = {})
        Socialization.mention_model.mentioners_relation(self, klass, opts)
      end

      # Returns the total count of all followers of an object, does not differentiate between types of followers.
      #
      # @return Integer
      def followers_count
        if self.has_attribute?(:followers_count)
          read_attribute(:followers_count)
        else
          raise "No liker_count column error"
        end
      end

      # Returns the total count of objects liked by liker, does not differentiate between types of followers.
      #
      # @return Integer
      def followables_count
        if self.has_attribute?(:followables_count)
          read_attribute(:followables_count)
        else
          raise "No followables_count column error"
        end
      end

    end
  end
end