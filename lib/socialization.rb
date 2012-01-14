require 'socialization/hello'

module Socialization
end

ActiveRecord::Base.send :include, Socialization::Hello
