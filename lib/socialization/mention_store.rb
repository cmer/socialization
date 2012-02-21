module Socialization
  module MentionStore
    def self.included(base)
      base.class_eval do
        belongs_to :mentionner,   :polymorphic => true
        belongs_to :mentionable,  :polymorphic => true

        validates_uniqueness_of :mentionable_type, :scope => [:mentionable_id, :mentionner_type, :mentionner_id], :message => 'You cannot mention the same thing twice in a given object.'

        def self.human_attribute_name(*args); ''; end
      end
    end
  end
end