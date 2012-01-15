require File.dirname(__FILE__)+'/test_helper'

class FollowTest < Test::Unit::TestCase
  def setup
    @u_john  = User.create :name => 'John Doe'
    @u_jane  = User.create :name => 'Jane Doe'
    @c_chuck = Celebrity.create :name => 'Chuck Norris'
    @c_uma   = Celebrity.create :name => 'Uma Thurman'
    @c_rick  = Celebrity.create :name => 'Rick Astley'
  end

  def test_the_world
    assert @u_john.is_follower?
    assert @c_chuck.is_followable?

    assert @u_john.follow!(@c_rick)
    assert @u_john.follow!(@c_chuck)
    assert @u_jane.follow!(@c_rick)

    assert_equal true, @u_john.follows?(@c_chuck)
    assert_equal true, @u_john.follows?(@c_rick)
    assert_equal true, @c_chuck.followed_by?(@u_john)

    assert @c_uma.followers.empty?

    # can't have duplicate follows
    assert_raise ActiveRecord::RecordInvalid do
      @u_john.follow!(@c_rick)
    end

    assert @u_john.unfollow!(@c_rick)
    assert_equal false, @c_rick.followed_by?(@u_john)
  end

  def test_user_following_user
    @u_john.follow!(@u_jane)
    assert_equal true,  @u_john.follows?(@u_jane)
    assert_equal false, @u_jane.follows?(@u_john)
  end
end