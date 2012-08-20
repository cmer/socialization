module ActiveRecord
  class Base
    def is_mentioner?
      false
    end
    alias mentioner? is_mentioner?
  end
end

module Socialization
  module Mentioner
    extend ActiveSupport::Concern

    included do
      after_destroy { Socialization.mention_model.remove_mentionables(self) }

      # Specifies if self can mention {Mentionable} objects.
      #
      # @return [Boolean]
      def is_mentioner?
        true
      end
      alias mentioner? is_mentioner?

      # Create a new {Mention mention} relationship.
      #
      # @param [Mentionable] mentionable the object to be mentioned.
      # @return [Boolean]
      def mention!(mentionable)
        raise Socialization::ArgumentError, "#{mentionable} is not mentionable!"  unless mentionable.respond_to?(:is_mentionable?) && mentionable.is_mentionable?
        Socialization.mention_model.mention!(self, mentionable)
      end

      # Delete a {Mention mention} relationship.
      #
      # @param [Mentionable] mentionable the object to unmention.
      # @return [Boolean]
      def unmention!(mentionable)
        raise Socialization::ArgumentError, "#{mentionable} is not mentionable!" unless mentionable.respond_to?(:is_mentionable?) && mentionable.is_mentionable?
        Socialization.mention_model.unmention!(self, mentionable)
      end

      # Toggles a {Mention mention} relationship.
      #
      # @param [Mentionable] mentionable the object to mention/unmention.
      # @return [Boolean]
      def toggle_mention!(mentionable)
        raise Socialization::ArgumentError, "#{mentionable} is not mentionable!" unless mentionable.respond_to?(:is_mentionable?) && mentionable.is_mentionable?
        if mentions?(mentionable)
          unmention!(mentionable)
          false
        else
          mention!(mentionable)
          true
        end
      end

      # Specifies if self mentions a {Mentionable} object.
      #
      # @param [Mentionable] mentionable the {Mentionable} object to test against.
      # @return [Boolean]
      def mentions?(mentionable)
        raise Socialization::ArgumentError, "#{mentionable} is not mentionable!" unless mentionable.respond_to?(:is_mentionable?) && mentionable.is_mentionable?
        Socialization.mention_model.mentions?(self, mentionable)
      end

      # Returns all the mentionables of a certain type that are mentioned by self
      #
      # @params [Mentionable] klass the type of {Mentionable} you want
      # @params [Hash] opts a hash of options
      # @return [Array<Mentionable, Numeric>] An array of Mentionable objects or IDs
      def mentionables(klass, opts = {})
        Socialization.mention_model.mentionables(self, klass, opts)
      end
      alias :mentionees :mentionables

      # Returns a relation for all the mentionables of a certain type that are mentioned by self
      #
      # @params [Mentionable] klass the type of {Mentionable} you want
      # @params [Hash] opts a hash of options
      # @return ActiveRecord::Relation
      def mentionables_relation(klass, opts = {})
        Socialization.mention_model.mentionables_relation(self, klass, opts)
      end
      alias :mentionees_relation :mentionables_relation
    end
  end
end