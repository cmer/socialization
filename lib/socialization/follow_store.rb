module Socialization
  module FollowStore
    extend ActiveSupport::Concern

    included do
      def self.human_attribute_name(*args); ''; end
    end
  end
end
