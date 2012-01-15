class Celebrity < ActiveRecord::Base
  acts_as_likeable
  acts_as_followable
end
