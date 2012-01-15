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
          raise ArgumentError, "#{follower} is not a follower!" unless follower.respond_to?(:is_follower?) && follower.is_follower?
          !self.followings.where(:follower_type => follower.class.to_s, :follower_id => follower.id).empty?
        end

        def followers
          self.followings.map { |f| f.follower }
        end
      end
    end
  end
end