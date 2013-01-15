module ActiveRecord
  class Base
    def is_likeable?
      false
    end
    alias likeable? is_likeable?
  end
end

module Socialization
  module Likeable
    extend ActiveSupport::Concern

    included do
      after_destroy { Socialization.like_model.remove_likers(self) }

      # Specifies if self can be liked.
      #
      # @return [Boolean]
      def is_likeable?
        true
      end
      alias likeable? is_likeable?

      # Specifies if self is liked by a {Liker} object.
      #
      # @return [Boolean]
      def liked_by?(liker)
        raise Socialization::ArgumentError, "#{liker} is not liker!"  unless liker.respond_to?(:is_liker?) && liker.is_liker?
        Socialization.like_model.likes?(liker, self)
      end

      # Returns an array of {Liker}s liking self.
      #
      # @param [Class] klass the {Liker} class to be included. e.g. `User`
      # @return [Array<Liker, Numeric>] An array of Liker objects or IDs
      def likers(klass, opts = {})
        Socialization.like_model.likers(self, klass, opts)
      end

      # Returns a scope of the {Liker}s liking self.
      #
      # @param [Class] klass the {Liker} class to be included in the scope. e.g. `User`
      # @return ActiveRecord::Relation
      def likers_relation(klass, opts = {})
        Socialization.like_model.likers_relation(self, klass, opts)
      end

      # Returns the total count of all likers of an object, does not differentiate between types of likers.
      #
      # @return Integer
      def likers_count
        if self.has_attribute?(:likers_count)
          read_attribute(:likers_count)
        else
          raise "No likers_count column error"
        end
      end

    end
  end
end