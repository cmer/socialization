module ActiveRecord
  class Base
    def is_follower?
      false
    end
  end
end

module Socialization
  module Follower
    def self.included(base)
      base.class_eval do
        # A follow is the Follow record of self following a followable record.
        has_many :follows, :as => :follower, :dependent => :destroy, :class_name => 'Follow'

        def is_follower?
          true
        end

        def follow!(followable)
          raise ArgumentError, "#{followable} is not followable!" unless followable.is_followable?
          raise ArgumentError, "#{self} cannot follow itself!" unless self != followable
          Follow.create!({ :follower => self, :followable => followable }, :without_protection => true)
        end

        def unfollow!(followable)
          ff = followable.followings.where(:follower_type => self.class.to_s, :follower_id => self.id)
          unless ff.empty?
            ff.each { |f| f.destroy }
          else
            raise ActiveRecord::RecordNotFound
          end
        end

        def follows?(followable)
          raise ArgumentError, "#{followable} is not followable!" unless followable.is_followable?
          !self.follows.where(:followable_type => followable.class.to_s, :followable_id => followable.id).empty?
        end

      end
    end
  end
end