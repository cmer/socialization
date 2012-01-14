module Socialization
  module LikeStore
    def self.included(base)
      base.class_eval do
        belongs_to :liker,    :polymorphic => true
        belongs_to :likeable, :polymorphic => true

        validates_uniqueness_of :likeable_type, :scope => [:likeable_id, :liker_type, :liker_id], :message => 'You cannot like the same thing twice.'

        def self.human_attribute_name(*args); ''; end
      end
    end
  end
end