require File.dirname(__FILE__)+'/test_helper'

class LikeTest < Test::Unit::TestCase
  def setup
    @u_john  = User.create :name => 'John Doe'
    @u_jane  = User.create :name => 'Jane Doe'
    @m_seven = Movie.create :name => 'Seven'
    @m_pulp  = Movie.create :name => 'Pulp Fiction'
    @m_tub   = Movie.create :name => 'Hot Tub Time Machine'
  end

  def test_the_world
    assert @u_john.is_liker?
    assert @u_john.is_likeable?
    assert @m_seven.is_likeable?

    assert @u_john.like!(@m_seven)
    assert @u_john.like!(@m_pulp)
    assert @u_jane.like!(@m_seven)

    assert_raise ArgumentError do
      @u_jane.follow!(@m_seven) # movie is not followable
    end

    assert_equal true, @u_john.likes?(@m_seven)
    assert_equal true, @u_john.likes?(@m_pulp)
    assert_equal true, @u_jane.likes?(@m_seven)
    assert_equal false, @u_jane.likes?(@m_pulp)

    assert_equal true, @m_seven.liked_by?(@u_john)
    assert_equal false, @m_pulp.liked_by?(@u_jane)

    assert @m_tub.likers.empty?

    # can't have duplicate a like
    assert_raise ActiveRecord::RecordInvalid do
      @u_john.like!(@m_seven)
    end
  end

  def test_user_liking_another_user
    @u_john.like!(@u_jane)
    assert_equal true,  @u_john.likes?(@u_jane)
    assert_equal false, @u_jane.likes?(@u_john)
  end
end