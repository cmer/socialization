module ActiveRecord
  class Base
    def is_liker?
      false
    end
  end
end

module Socialization
  module Liker
    extend ActiveSupport::Concern

    included do
      # A like is the Like record of self liking a likeable record.
      has_many :likes, :as => :liker, :dependent => :destroy, :class_name => 'Like'

      # Specifies if self can like {Likeable} objects.
      #
      # @return [Boolean]
      def is_liker?
        true
      end

      # Create a new {LikeStore like} relationship.
      #
      # @param [Likeable] likeable the object to be liked.
      # @return [LikeStore] the newly created {LikeStore like} record.
      def like!(likeable)
        ensure_likeable!(likeable)
        raise ArgumentError, "#{self} cannot like itself!" unless self != likeable
        Like.create! do |like|
          like.liker = self
          like.likeable = likeable
        end
      end

      # Delete a {LikeStore like} relationship.
      #
      # @param [Likeable] likeable the object to unlike.
      # @return [Boolean]
      def unlike!(likeable)
        ll = likeable.likings.where(:liker_type => self.class.to_s, :liker_id => self.id)
        unless ll.empty?
          ll.each { |l| l.destroy }
        else
          raise ActiveRecord::RecordNotFound
        end
      end

      # Toggles a {LikeStore like} relationship.
      #
      # @param [Likeable] likeable the object to like/unlike.
      # @return [Boolean]
      def toggle_like!(likeable)
        if likes?(likeable)
          unlike!(likeable)
          false
        else
          like!(likeable)
          true
        end
      end

      # Specifies if self likes a {Likeable} object.
      #
      # @param [Likeable] likeable the {Likeable} object to test against.
      # @return [Boolean]
      def likes?(likeable)
        ensure_likeable!(likeable)
        !self.likes.where(:likeable_type => likeable.class.table_name.classify, :likeable_id => likeable.id).empty?
      end

      # Returns a scope of the {Likeable}s followed by self.
      #
      # @param [Class] klass the {Likeable} class to be included in the scope. e.g. `Movie`.
      # @return [ActiveRecord::Relation]
      def likees(klass)
        klass = klass.to_s.singularize.camelize.constantize unless klass.is_a?(Class)
        klass.joins("INNER JOIN likes ON likes.likeable_id = #{klass.to_s.tableize}.id AND likes.likeable_type = '#{klass.to_s}'").
              where("likes.liker_type = '#{self.class.to_s}'").
              where("likes.liker_id   =  #{self.id}")
      end

      # Add a shortcut for the +likees+ method combined with the name of the class.
      # This allows you to ask for <tt>user_likees</tt> instead of <tt>likees(User)</tt>.
      def method_missing(method, *arguments, &block)
        if method.to_s =~ /(.*)_likees$/
          likees($1)
        else
          super
        end
      end

       # Assert that this class responds to the dynamic likees-method.
      def respond_to?(method)
        if method.to_s =~ /(.*)_likees$/
          true
        else
          super
        end
      end

      private
        def ensure_likeable!(likeable)
          raise ArgumentError, "#{likeable} is not likeable!" unless likeable.is_likeable?
        end
    end
  end
end
