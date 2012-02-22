module Socialization
  module FollowStore
    extend ActiveSupport::Concern

    included do
      belongs_to :follower,   :polymorphic => true
      belongs_to :followable, :polymorphic => true

      validates_uniqueness_of :followable_type, :scope => [:followable_id, :follower_type, :follower_id], :message => 'You cannot follow the same thing twice.'

      def self.human_attribute_name(*args); ''; end
    end
  end
end
