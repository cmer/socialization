module Socialization
  module MentionStore
    extend ActiveSupport::Concern

    included do
      belongs_to :mentioner,   :polymorphic => true
      belongs_to :mentionable, :polymorphic => true

      validates_uniqueness_of :mentionable_type, :scope => [:mentionable_id, :mentioner_type, :mentioner_id], :message => 'You cannot mention the same thing twice in a given object.'

      def self.human_attribute_name(*args); ''; end
    end
  end
end