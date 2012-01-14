%w{followable follower follow_store likeable liker like_store}.each do |f|
  require "#{File.dirname(__FILE__)}/#{f}"
end

module Socialization
  module Hello
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      def acts_as_follower(opts = nil)
        include Socialization::Follower
      end

      def acts_as_followable(opts = nil)
        include Socialization::Followable
      end

      def acts_as_follow_store(opts = nil)
        include Socialization::FollowStore
      end

      def acts_as_liker(opts = nil)
        include Socialization::Liker
      end

      def acts_as_likeable(opts = nil)
        include Socialization::Likeable
      end

      def acts_as_like_store(opts = nil)
        include Socialization::LikeStore
      end
    end
  end
end