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
      # the mentioner and the mentionable (self).
      has_many :mentionings, :as => :mentionable, :dependent => :destroy, :class_name => 'Mention'

      def is_mentionable?
        true
      end

      def mentioned_by?(mentioner)
        raise ArgumentError, "#{mentioner} is not a mentioner!" unless mentioner.is_mentioner?
        !self.mentionings.where(:mentioner_type => mentioner.class.to_s, :mentioner_id => mentioner.id).empty?
      end

      def mentioners(klass)
        klass = klass.to_s.singularize.camelize.constantize unless klass.is_a?(Class)
        klass.joins("INNER JOIN mentions ON mentions.mentioner_id = #{klass.to_s.tableize}.id AND mentions.mentioner_type = '#{klass.to_s}'").
              where("mentions.mentionable_type = '#{self.class.to_s}'").
              where("mentions.mentionable_id   =  #{self.id}")
      end

    end
  end
end