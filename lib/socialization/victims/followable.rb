module ActiveRecord
  class Base
    def is_followable?
      false
    end
  end
end

module Socialization
  module Followable
    extend ActiveSupport::Concern

    included do
      # Specifies if self can be followed.
      #
      # @return [Boolean]
      def is_followable?
        true
      end

      # Specifies if self is followed by a {Follower} object.
      #
      # @return [Boolean]
      def followed_by?(follower)
        raise ArgumentError, "#{follower} is not follower!"  unless follower.respond_to?(:is_follower?) && follower.is_follower?
        Follow.follows?(follower, self)
      end

      # Returns a scope of the {Follower}s following self.
      #
      # @param [Class] klass the {Follower} class to be included in the scope. e.g. `User`
      # @return [Array<Follower, Numeric>] An array of Follower objects or IDs
      def followers(klass, opts = {})
        Follow.followers(self, klass, opts)
      end
    end
  end
end
