class Comment < ActiveRecord::Base
  acts_as_mentionner
  belongs_to :user
  belongs_to :movie
end
