module ActiveRecord
  class Base
    def is_follower?
      false
    end
    alias follower? is_follower?
  end
end

module Socialization
  module Follower
    extend ActiveSupport::Concern

    included do
      after_destroy { Socialization.follow_model.remove_followables(self) }

      # Specifies if self can follow {Followable} objects.
      #
      # @return [Boolean]
      def is_follower?
        true
      end
      alias follower? is_follower?

      # Create a new {Follow follow} relationship.
      #
      # @param [Followable] followable the object to be followed.
      # @return [Boolean]
      def follow!(followable)
        raise Socialization::ArgumentError, "#{followable} is not followable!"  unless followable.respond_to?(:is_followable?) && followable.is_followable?
        Socialization.follow_model.follow!(self, followable)
      end

      # Delete a {Follow follow} relationship.
      #
      # @param [Followable] followable the object to unfollow.
      # @return [Boolean]
      def unfollow!(followable)
        raise Socialization::ArgumentError, "#{followable} is not followable!" unless followable.respond_to?(:is_followable?) && followable.is_followable?
        Socialization.follow_model.unfollow!(self, followable)
      end

      # Toggles a {Follow follow} relationship.
      #
      # @param [Followable] followable the object to follow/unfollow.
      # @return [Boolean]
      def toggle_follow!(followable)
        raise Socialization::ArgumentError, "#{followable} is not followable!" unless followable.respond_to?(:is_followable?) && followable.is_followable?
        if follows?(followable)
          unfollow!(followable)
          false
        else
          follow!(followable)
          true
        end
      end

      # Specifies if self follows a {Followable} object.
      #
      # @param [Followable] followable the {Followable} object to test against.
      # @return [Boolean]
      def follows?(followable)
        raise Socialization::ArgumentError, "#{followable} is not followable!" unless followable.respond_to?(:is_followable?) && followable.is_followable?
        Socialization.follow_model.follows?(self, followable)
      end

      # Returns all the followables of a certain type that are followed by self
      #
      # @params [Followable] klass the type of {Followable} you want
      # @params [Hash] opts a hash of options
      # @return [Array<Followable, Numeric>] An array of Followable objects or IDs
      def followables(klass, opts = {})
        Socialization.follow_model.followables(self, klass, opts)
      end
      alias :followees :followables

      # Returns a relation for all the followables of a certain type that are followed by self
      #
      # @params [Followable] klass the type of {Followable} you want
      # @params [Hash] opts a hash of options
      # @return ActiveRecord::Relation
      def followables_relation(klass, opts = {})
        Socialization.follow_model.followables_relation(self, klass, opts)
      end
      alias :followees_relation :followables_relation
    end
  end
end