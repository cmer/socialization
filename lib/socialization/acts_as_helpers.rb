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
      # @param [Hash] opts the options to create a message with.
      # @option opts [Boolean] :touch_follower :touch value for belongs_to :follower association
      # @option opts [Boolean] :touch_followable :touch value for belongs_to :followable association
      def acts_as_follow_store(opts = nil)
        opts ||= {}
        belongs_to :follower,   :polymorphic => true, :touch => opts[:touch_follower]   || false
        belongs_to :followable, :polymorphic => true, :touch => opts[:touch_followable] || false
        validates_uniqueness_of :followable_type, :scope => [:followable_id, :follower_type, :follower_id], :message => 'You cannot follow the same thing twice.'
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
      # @param [Hash] opts the options to create a message with.
      # @option opts [Boolean] :touch_liker :touch value for belongs_to :liker association
      # @option opts [Boolean] :touch_likeable :touch value for belongs_to :likeable association
      def acts_as_like_store(opts = nil)
        opts ||= {}
        belongs_to :liker,    :polymorphic => true, :touch => opts[:touch_liker]    || false
        belongs_to :likeable, :polymorphic => true, :touch => opts[:touch_likeable] || false
        validates_uniqueness_of :likeable_type, :scope => [:likeable_id, :liker_type, :liker_id], :message => 'You cannot like the same thing twice.'
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
      # @param [Hash] opts the options to create a message with.
      # @option opts [Boolean] :touch_mentioner :touch value for belongs_to :mentioner association
      # @option opts [Boolean] :touch_mentionable :touch value for belongs_to :mentionable association
      def acts_as_mention_store(opts = nil)
        opts ||= {}
        belongs_to :mentioner,   :polymorphic => true, :touch => opts[:touch_mentioner]   || false
        belongs_to :mentionable, :polymorphic => true, :touch => opts[:touch_mentionable] || false
        validates_uniqueness_of :mentionable_type, :scope => [:mentionable_id, :mentioner_type, :mentioner_id], :message => 'You cannot mention the same thing twice in a given object.'
        include Socialization::MentionStore
      end

    end
  end
end
