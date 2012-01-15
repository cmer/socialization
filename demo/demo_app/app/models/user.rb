class User < ActiveRecord::Base
  acts_as_follower
  acts_as_followable

  acts_as_liker
end
