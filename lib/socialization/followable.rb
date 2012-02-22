module ActiveRecord
  class Base
    def is_followable?
      false
    end
  end
end

module Socialization
  module Followable
    def self.included(base)
      base.class_eval do
        # A following is the Follow record of the follower following self.
        has_many :followings, :as => :followable, :dependent => :destroy, :class_name => 'Follow'

        def is_followable?
          true
        end

        def followed_by?(follower)
          raise ArgumentError, "#{follower} is not a follower!" unless follower.is_follower?
          !self.followings.where(:follower_type => follower.class.to_s, :follower_id => follower.id).empty?
        end

        def followers(klass)
          klass = klass.to_s.singularize.camelize.constantize unless klass.is_a?(Class)
          klass.joins("INNER JOIN follows ON follows.follower_id = #{klass.to_s.tableize}.id AND follows.follower_type = '#{klass.to_s}'").
                where("follows.followable_type = '#{self.class.to_s}'").
                where("follows.followable_id   =  #{self.id}")
        end
      end
    end
  end
end