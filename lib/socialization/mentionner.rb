module ActiveRecord
  class Base
    def is_mentionner?
      false
    end
  end
end

module Socialization
  module Mentionner
    extend ActiveSupport::Concern

    included do
      # A mention is the Mention record (self) mentionning a mentionable record.
      has_many :mentions, :as => :mentionner, :dependent => :destroy, :class_name => 'Mention'

      def is_mentionner?
        true
      end

      def mention!(mentionable)
        ensure_mentionable!(mentionable)
        Mention.create!({ :mentionner => self, :mentionable => mentionable }, :without_protection => true)
      end

      def unmention!(mentionable)
        mm = mentionable.mentionings.where(:mentionner_type => self.class.to_s, :mentionner_id => self.id)
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

      private
        def ensure_mentionable!(mentionable)
          raise ArgumentError, "#{mentionable} is not mentionable!" unless mentionable.is_mentionable?
        end

    end
  end
end