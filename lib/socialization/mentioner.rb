module ActiveRecord
  class Base
    def is_mentioner?
      false
    end
  end
end

module Socialization
  module Mentioner
    extend ActiveSupport::Concern

    included do
      # A mention is the Mention record (self) mentionning a mentionable record.
      has_many :mentions, :as => :mentioner, :dependent => :destroy, :class_name => 'Mention'

      def is_mentioner?
        true
      end

      def mention!(mentionable)
        ensure_mentionable!(mentionable)
        Mention.create!({ :mentioner => self, :mentionable => mentionable }, :without_protection => true)
      end

      def unmention!(mentionable)
        mm = mentionable.mentionings.where(:mentioner_type => self.class.to_s, :mentioner_id => self.id)
        unless mm.empty?
          mm.each { |m| m.destroy }
        else
          raise ActiveRecord::RecordNotFound
        end
      end

      def mentions?(mentionable)
        ensure_mentionable!(mentionable)
        !self.mentions.where(:mentionable_type => mentionable.class.to_s, :mentionable_id => mentionable.id).empty?
      end

      def mentionees(klass)
        klass = klass.to_s.singularize.camelize.constantize unless klass.is_a?(Class)
        klass.joins("INNER JOIN mentions ON mentions.mentionable_id = #{klass.to_s.tableize}.id AND mentions.mentionable_type = '#{klass.to_s}'").
              where("mentions.mentioner_type = '#{self.class.to_s}'").
              where("mentions.mentioner_id   =  #{self.id}")
      end

      private
        def ensure_mentionable!(mentionable)
          raise ArgumentError, "#{mentionable} is not mentionable!" unless mentionable.is_mentionable?
        end

    end
  end
end
