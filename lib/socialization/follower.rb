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
          raise ArgumentError, "#{followable} is not followable!" unless followable.respond_to?(:is_followable?)
          Follow.create! follower: self, followable: followable
        end

        def unfollow!(followable)
          followable.followers.where(:follower => self).each do |f|
            f.destroy
          end
        end

        def follows?(followable)
          raise ArgumentError, "#{followable} is not followable!" unless followable.respond_to?(:is_followable?) && followable.is_followable?
          !self.follows.where(:followable_type => followable.class.to_s, :followable_id => followable.id).pluck("1").empty?
        end

      end
    end
  end
end