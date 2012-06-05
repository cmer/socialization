class Comment < ActiveRecord::Base
  acts_as_mentioner
  belongs_to :user
  belongs_to :movie
end
