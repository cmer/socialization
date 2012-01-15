require File.dirname(__FILE__)+'/test_helper'

class FollowTest < Test::Unit::TestCase
  context "a Follower" do
    setup do
      seed
    end

    should "respond to is_follower?" do
      assert_equal true, @follower1.respond_to?(:is_follower?)
      assert_equal true, @follower1.is_follower?
    end

    should "be able to follow a Followable" do
      assert @follower1.follow!(@followable1)
      assert_equal true, @follower1.follows?(@followable1)
      assert_equal false, @follower2.follows?(@followable1)
    end

    should "be able to unfollow a Followable" do
      Follow.create :follower => @follower1, :followable => @followable1
      assert @follower1.unfollow!(@followable1)
      assert_equal false, @follower1.follows?(@followable1)
    end
  end

  context "a Followable" do
    setup do
      seed
    end

    should "respond to is_followable?" do
      assert_equal true, @followable1.respond_to?(:is_followable?)
      assert_equal true, @followable1.is_followable?
    end

    should "be able to determine who follows it" do
      Follow.create :follower => @follower1, :followable => @followable1
      assert_equal true, @followable1.followed_by?(@follower1)
      assert_equal false, @followable1.followed_by?(@follower2)
    end

    should "expose a list of its followers" do
      Follow.create :follower => @follower1, :followable => @followable1
      assert_equal [@follower1], @followable1.followers
    end

    should "expose followings" do
      Follow.create :follower => @follower1, :followable => @followable1
      followings = @followable1.followings
      assert_equal 1, followings.size
      assert followings.first.is_a?(Follow)
    end
  end

  context "Deleting a Follower" do
    setup do
      seed
      @follower1.follow!(@followable1)
    end

    should "delete its Follow records" do
      @follower1.destroy
      assert_equal false, @followable1.followed_by?(@follower1)
    end
  end

  context "Deleting a Followable" do
    setup do
      seed
      @follower1.follow!(@followable1)
    end

    should "delete its Follow records" do
      @followable1.destroy
      assert_equal false, @follower1.follows?(@followable1)
    end
  end

  def seed
    @follower1 = ImAFollower.create
    @follower2 = ImAFollower.create
    @followable1 = ImAFollowable.create
    @followable2 = ImAFollowable.create
  end
end