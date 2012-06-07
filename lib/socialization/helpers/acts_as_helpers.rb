require 'active_support/concern'

module Socialization
  module ActsAsHelpers
    extend ActiveSupport::Concern

    module ClassMethods
      # Make the current class a {Socialization::Follower}
      def acts_as_follower(opts = {})
        include Socialization::Follower
      end

      # Make the current class a {Socialization::Followable}
      def acts_as_followable(opts = {})
        include Socialization::Followable
      end

      # Make the current class a {Socialization::Liker}
      def acts_as_liker(opts = {})
        include Socialization::Liker
      end

      # Make the current class a {Socialization::Likeable}
      def acts_as_likeable(opts = {})
        include Socialization::Likeable
      end

      # Make the current class a {Socialization::Mentioner}
      def acts_as_mentioner(opts = {})
        include Socialization::Mentioner
      end

      # Make the current class a {Socialization::Mentionable}
      def acts_as_mentionable(opts = {})
        include Socialization::Mentionable
      end
    end
  end
end
