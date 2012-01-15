module Socialization
  module Liker
    def self.included(base)
      base.class_eval do
        # A like is the Like record of self liking a likeable record.
        has_many :likes, :as => :liker, :dependent => :destroy, :class_name => 'Like'

        def is_liker?
          true
        end

        def like!(likeable)
          raise ArgumentError, "#{likeable} is not likeable!" unless likeable.respond_to?(:is_likeable?)
          raise ArgumentError, "#{self} cannot like itself!" unless self != likeable
          Like.create! :liker => self, :likeable => likeable
        end

        def unlike!(likeable)
          ll = likeable.likings.where(:liker_type => self.class.to_s, :liker_id => self.id)
          unless ll.empty?
            ll.each { |l| l.destroy }
          else
            raise ActiveRecord::RecordNotFound
          end
        end

        def likes?(likeable)
          raise ArgumentError, "#{likeable} is not likeable!" unless likeable.respond_to?(:is_likeable?) && likeable.is_likeable?
          !self.likes.where(:likeable_type => likeable.class.to_s, :likeable_id => likeable.id).empty?
        end

      end
    end
  end
end