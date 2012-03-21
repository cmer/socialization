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
      # A following is the {FollowStore follow} record of the follower following self.
      has_many :followings, :as => :followable, :dependent => :destroy, :class_name => 'Follow'

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
        raise ArgumentError, "#{follower} is not a follower!" unless follower.is_follower?
        !self.followings.where(:follower_type => follower.class.to_s, :follower_id => follower.id).empty?
      end

      # Returns a scope of the {Follower}s following self.
      #
      # @param [Class] klass the {Follower} class to be included in the scope. e.g. `User`.
      # @return [ActiveRecord::Relation]
      def followers(klass)
        klass = klass.to_s.singularize.camelize.constantize unless klass.is_a?(Class)
        klass.joins("INNER JOIN follows ON follows.follower_id = #{klass.to_s.tableize}.id AND follows.follower_type = '#{klass.to_s}'").
              where("follows.followable_type = '#{self.class.to_s}'").
              where("follows.followable_id   =  #{self.id}")
      end

      # Add a shortcut for the +followers+ method combined with the name of the class.
      # This allows you to ask for <tt>user_followers</tt> instead of <tt>followers(User)</tt>.
      def method_missing(method, *arguments, &block)
        if method.to_s =~ /(.*)_followers$/
          followers($1)
        else
          super
        end
      end

      # Assert that this class responds to the dynamic followers-method.
      def respond_to?(method)
        if method.to_s =~ /(.*)_followers$/
          true
        else
          super
        end
      end
    end
  end
end
