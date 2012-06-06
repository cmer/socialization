require 'socialization/config'
require 'socialization/acts_as_helpers'

ActiveRecord::Base.send :include, Socialization::ActsAsHelpers
