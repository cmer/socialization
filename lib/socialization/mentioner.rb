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

      # Specifies if self can mention {Mentionable} objects.
      #
      # @return [Boolean]
      def is_mentioner?
        true
      end

      # Create a new {MentionStore mention} relationship.
      #
      # @param [Mentionable] mentionable the object to be mentioned.
      # @return [MentionStore] the newly created {MentionStore mention} record.
      def mention!(mentionable)
        ensure_mentionable!(mentionable)
        Mention.create!({ :mentioner => self, :mentionable => mentionable }, :without_protection => true)
      end

      # Delete a {MentionStore mention} relationship.
      #
      # @param [Mentionable] mentionable the object to unmention.
      # @return [Boolean]
      def unmention!(mentionable)
        mm = mentionable.mentionings.where(:mentioner_type => self.class.to_s, :mentioner_id => self.id)
        unless mm.empty?
          mm.each { |m| m.destroy }
        else
          raise ActiveRecord::RecordNotFound
        end
      end
      #
      # Toggles a {MentionStore mention} relationship.
      #
      # @param [Mentionable] mentionable the object to mention/unmention.
      # @return [Boolean]
      def toggle_mention!(mentionable)
        if mentions?(mentionable)
          unmention!(mentionable)
          false
        else
          mention!(mentionable)
          true
        end
      end

      # Specifies if self mentions a {Mentionable} object.
      #
      # @param [Mentionable] mentionable the {Mentionable} object to test against.
      # @return [Boolean]
      def mentions?(mentionable)
        ensure_mentionable!(mentionable)
        !self.mentions.where(:mentionable_type => mentionable.class.table_name.classify, :mentionable_id => mentionable.id).empty?
      end

      # Returns a scope of the {Mentionable}s mentioned by self.
      #
      # @param [Class] klass the {Mentionable} class to be included in the scope. e.g. `User`.
      # @return [ActiveRecord::Relation]
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
