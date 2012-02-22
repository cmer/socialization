module ActiveRecord
  class Base
    def is_mentionable?
      false
    end
  end
end

module Socialization
  module Mentionable
    extend ActiveSupport::Concern

    included do
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

      def mentionners(klass)
        klass = klass.to_s.singularize.camelize.constantize unless klass.is_a?(Class)
        klass.joins("INNER JOIN mentions ON mentions.mentionner_id = #{klass.to_s.tableize}.id AND mentions.mentionner_type = '#{klass.to_s}'").
              where("mentions.mentionable_type = '#{self.class.to_s}'").
              where("mentions.mentionable_id   =  #{self.id}")
      end

    end
  end
end