module ActiveRecord
  class Base
    def is_follower?
      false
    end
  end
end

module Socialization
  module Follower
    extend ActiveSupport::Concern

    included do
      # A follow is the Follow record of self following a followable record.
      has_many :follows, :as => :follower, :dependent => :destroy, :class_name => 'Follow'

      # Specifies if self can follow {Followable} objects.
      #
      # @return [Boolean]
      def is_follower?
        true
      end

      # Create a new {FollowStore follow} relationship.
      #
      # @param [Followable] followable the object to be followed.
      # @return [FollowStore] the newly created {FollowStore follow} record.
      def follow!(followable)
        raise ArgumentError, "#{followable} is not followable!" unless followable.is_followable?
        raise ArgumentError, "#{self} cannot follow itself!" unless self != followable
        Follow.create!({ :follower => self, :followable => followable }, :without_protection => true)
      end

      # Delete a {FollowStore follow} relationship.
      #
      # @param [Followable] followable the object to unfollow.
      # @return [Boolean]
      def unfollow!(followable)
        ff = followable.followings.where(:follower_type => self.class.to_s, :follower_id => self.id)
        unless ff.empty?
          ff.each { |f| f.destroy }
        else
          raise ActiveRecord::RecordNotFound
        end
        true
      end

      # Toggles a {FollowStore follow} relationship.
      #
      # @param [Followable] followable the object to follow/unfollow.
      # @return [Boolean]
      def toggle_follow!(followable)
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
        raise ArgumentError, "#{followable} is not followable!" unless followable.is_followable?
        !self.follows.where(:followable_type => followable.class.table_name.classify, :followable_id => followable.id).empty?
      end

      # Returns a scope of the {Followable}s followed by self.
      #
      # @param [Class] klass the {Followable} class to be included in the scope. e.g. `User`.
      # @return [ActiveRecord::Relation]
      def followees(klass)
        klass = klass.to_s.singularize.camelize.constantize unless klass.is_a?(Class)
        klass.joins("INNER JOIN follows ON follows.followable_id = #{klass.to_s.tableize}.id AND follows.followable_type = '#{klass.to_s}'").
              where("follows.follower_type = '#{self.class.to_s}'").
              where("follows.follower_id   =  #{self.id}")

      end
    end
  end
end
