module ActiveRecord
  class Base
    def is_likeable?
      false
    end
  end
end

module Socialization
  module Likeable
    extend ActiveSupport::Concern

    included do
      # A liking is the {Like} record of the liker liking self.
      has_many :likings, :as => :likeable, :dependent => :destroy, :class_name => 'Like'

      # Specifies if self can be liked.
      #
      # @return [Boolean]
      def is_likeable?
        true
      end

      # Specifies if self is liked by a {Liker} object.
      #
      # @return [Boolean]
      def liked_by?(liker)
        raise ArgumentError, "#{liker} is not a liker!" unless liker.is_liker?
        !self.likings.where(:liker_type => liker.class.to_s, :liker_id => liker.id).empty?
      end

      # Returns a scope of the {Liker}s liking self.
      #
      # @param [Class] klass the {Liker} class to be included in the scope. e.g. `User`.
      # @return [ActiveRecord::Relation]
      def likers(klass)
        klass = klass.to_s.singularize.camelize.constantize unless klass.is_a?(Class)
        klass.joins("INNER JOIN likes ON likes.liker_id = #{klass.to_s.tableize}.id AND likes.liker_type = '#{klass.to_s}'").
              where("likes.likeable_type = '#{self.class.to_s}'").
              where("likes.likeable_id   =  #{self.id}")
      end

      # Add a shortcut for the +likers+ method combined with the name of the class.
      # This allows you to ask for <tt>user_likers</tt> instead of <tt>likers(User)</tt>.
      def method_missing(method, *arguments, &block)
        if method.to_s =~ /(.*)_likers$/
          likers($1)
        else
          super
        end
      end

      # Assert that this class responds to the dynamic likers-method.
      def respond_to?(method)
        if method.to_s =~ /(.*)_likers$/
          true
        else
          super
        end
      end
    end
  end
end
