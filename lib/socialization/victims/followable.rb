module ActiveRecord
  class Base
    def is_followable?
      false
    end
    alias followable? is_followable?
  end
end

module Socialization
  module Followable
    extend ActiveSupport::Concern

    included do
      after_destroy { Socialization.follow_model.remove_followers(self) }

      # Specifies if self can be followed.
      #
      # @return [Boolean]
      def is_followable?
        true
      end
      alias followable? is_followable?

      # Specifies if self is followed by a {Follower} object.
      #
      # @return [Boolean]
      def followed_by?(follower)
        raise Socialization::ArgumentError, "#{follower} is not follower!"  unless follower.respond_to?(:is_follower?) && follower.is_follower?
        Socialization.follow_model.follows?(follower, self)
      end

      # Returns an array of {Follower}s following self.
      #
      # @param [Class] klass the {Follower} class to be included. e.g. `User`
      # @return [Array<Follower, Numeric>] An array of Follower objects or IDs
      def followers(klass, opts = {})
        Socialization.follow_model.followers(self, klass, opts)
      end

      # Returns a scope of the {Follower}s following self.
      #
      # @param [Class] klass the {Follower} class to be included in the scope. e.g. `User`
      # @return ActiveRecord::Relation
      def followers_relation(klass, opts = {})
        Socialization.follow_model.followers_relation(self, klass, opts)
      end

      # Returns the total count of all followers of an object, does not differentiate between types of followers.
      #
      # @return Integer
      def follower_count
        if self.has_attribute?(:followers_count)
          read_attribute(:followers_count)
        else
          raise "No follower_count column error"
        end
      end

      # Returns the total count of objects liked by follower, does not differentiate between types of followers.
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