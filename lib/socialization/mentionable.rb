module ActiveRecord
  class Base
    def is_mentionable?
      false
    end
  end
end

module Socialization
  module Mentionable
    def self.included(base)
      base.class_eval do
        # A mentioning is the Mention record of describing the mention relationship between
        # the mentionner and the mentionable (self).
        has_many :mentionings, :as => :mentionable, :dependent => :destroy, :class_name => 'Mention'

        def is_mentionable?
          true
        end

        def mentioned_by?(mentionner)
          raise ArgumentError, "#{mentionner} is not a mentionner!" unless mentionner.is_mentionner?
          !self.mentionings.where(:mentionner_type => mentionner.class.to_s, :mentionner_id => mentionner.id).empty?
        end

        def mentionners
          self.mentionings.map { |f| f.mentionner }
        end
      end
    end
  end
end