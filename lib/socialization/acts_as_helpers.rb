require 'active_support/concern'

%w{followable follower follow_store likeable liker like_store mentionable mentioner mention_store}.each do |f|
  require "#{File.dirname(__FILE__)}/#{f}"
end

module Socialization
  module ActsAsHelpers
    extend ActiveSupport::Concern

    module ClassMethods
      # Make the current class a {Socialization::Follower}
      def acts_as_follower(opts = nil)
        include Socialization::Follower
      end

      # Make the current class a {Socialization::Followable}
      def acts_as_followable(opts = nil)
        include Socialization::Followable
      end

      # Make the current class a {Socialization::FollowStore}
      def acts_as_follow_store(opts = nil)
        include Socialization::FollowStore
      end

      # Make the current class a {Socialization::Liker}
      def acts_as_liker(opts = nil)
        include Socialization::Liker
      end

      # Make the current class a {Socialization::Likeable}
      def acts_as_likeable(opts = nil)
        include Socialization::Likeable
      end

      # Make the current class a {Socialization::LikeStore}
      def acts_as_like_store(opts = nil)
        include Socialization::LikeStore
      end

      # Make the current class a {Socialization::Mentioner}
      def acts_as_mentioner(opts = nil)
        include Socialization::Mentioner
      end

      # Make the current class a {Socialization::Mentionable}
      def acts_as_mentionable(opts = nil)
        include Socialization::Mentionable
      end

      # Make the current class a {Socialization::MentionStore}
      def acts_as_mention_store(opts = nil)
        include Socialization::MentionStore
      end

    end
  end
end
