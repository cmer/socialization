module ActiveRecord
  class Base
    def is_likeable?
      false
    end
  end
end

module Socialization
  module Likeable
    def self.included(base)
      base.class_eval do
        # A liking is the Like record of the liker liking self.
        has_many :likings, :as => :likeable, :dependent => :destroy, :class_name => 'Like'

        def is_likeable?
          true
        end

        def liked_by?(liker)
          raise ArgumentError, "#{liker} is not a liker!" unless liker.is_liker?
          !self.likings.where(:liker_type => liker.class.to_s, :liker_id => liker.id).empty?
        end

        def likers
          self.likings.map { |l| l.liker }
        end
      end
    end
  end
end