require 'socialization/acts_as_helpers'

module Socialization
end

ActiveRecord::Base.send :include, Socialization::ActsAsHelpers
