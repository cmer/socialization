module ActiveRecord
  class Base
    def is_mentionable?
      false
    end
  end
end

module Socialization
  module Mentionable
    extend ActiveSupport::Concern

    included do
      # Specifies if self can be mentioned.
      #
      # @return [Boolean]
      def is_mentionable?
        true
      end

      # Specifies if self is mentioned by a {Mentioner} object.
      #
      # @return [Boolean]
      def mentioned_by?(mentioner)
        raise ArgumentError, "#{mentioner} is not mentioner!"  unless mentioner.respond_to?(:is_mentioner?) && mentioner.is_mentioner?
        Mention.mentions?(mentioner, self)
      end

      # Returns a scope of the {Mentioner}s mentioning self.
      #
      # @param [Class] klass the {Mentioner} class to be included in the scope. e.g. `User`.
      # @return [Array<Mentioner, Numeric>] An array of Mentioner objects or IDs
      def mentioners(klass, opts = {})
        Mention.mentioners(self, klass, opts)
      end
    end
  end
end
