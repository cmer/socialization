require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class FollowTest < Test::Unit::TestCase
  context "a Follower" do
    setup do
      seed
    end

    should "be follower" do
      assert_true  @follower1.is_follower?
    end

    should "be able to follow a Followable" do
      assert @follower1.follow!(@followable1)
      assert_true  @follower1.follows?(@followable1)
      assert_false @follower2.follows?(@followable1)
    end

    should "be able to unfollow a Followable" do
      Follow.create :follower => @follower1, :followable => @followable1
      assert @follower1.unfollow!(@followable1)
      assert_false @follower1.follows?(@followable1)
    end

    should "not be able to follow the same thing twice" do
      assert @follower1.follow!(@followable1)

      assert_raise ActiveRecord::RecordInvalid do
        @follower1.follow!(@followable1)
      end
    end

    should "not be able to unfollow something that is not followed" do
      assert_raise ActiveRecord::RecordNotFound do
        @follower1.unfollow!(@followable1)
      end
    end

    should "be able to toggle following on/off" do
      assert_false @follower1.follows?(@followable1)
      assert_true  @follower1.toggle_follow!(@followable1)
      assert_true  @follower1.follows?(@followable1)
      assert_false @follower1.toggle_follow!(@followable1)
      assert_false @follower1.follows?(@followable1)
      assert_true  @follower1.toggle_follow!(@followable1)
      assert_true  @follower1.follows?(@followable1)
    end

    should "expose a list of its followees" do
      Follow.create :follower => @follower1, :followable => @followable1
      assert @follower1.followees(ImAFollowable).is_a?(ActiveRecord::Relation)
      assert_equal [@followable1], @follower1.followees(ImAFollowable).all

      assert_equal @follower1.followees(ImAFollowable), @follower1.followees(:im_a_followables)
      assert_equal @follower1.followees(ImAFollowable), @follower1.followees("im_a_followable")
    end
  end

  context "a Followable" do
    setup do
      seed
    end

    should "be followable" do
      assert_true  @followable1.is_followable?
    end

    should "be able to determine who follows it" do
      Follow.create :follower => @follower1, :followable => @followable1
      assert_true  @followable1.followed_by?(@follower1)
      assert_false @followable1.followed_by?(@follower2)
    end

    should "expose a list of its followers" do
      Follow.create :follower => @follower1, :followable => @followable1
      assert @followable1.followers(ImAFollower).is_a?(ActiveRecord::Relation)
      assert_equal [@follower1], @followable1.followers(ImAFollower).all

      assert_equal @followable1.followers(ImAFollower), @followable1.followers(:im_a_followers)
      assert_equal @followable1.followers(ImAFollower), @followable1.followers("im_a_follower")
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
      assert_false @followable1.followed_by?(@follower1)
    end
  end

  context "Deleting a Followable" do
    setup do
      seed
      @follower1.follow!(@followable1)
    end

    should "delete its Follow records" do
      @followable1.destroy
      assert_false @follower1.follows?(@followable1)
    end
  end

  context "Virgin ActiveRecord::Base objects" do
    setup do
      @foo = Vanilla.new
    end

    should "not be follower" do
      assert_false @foo.is_follower?
    end

    should "not be followable" do
      assert_false @foo.is_followable?
    end
  end

  context "acts_as_follow_store" do
    should "touch associated record when touch_follower and/or touch_followable are set" do
      class Foo < ActiveRecord::Base
        self.table_name = 'follows'; acts_as_follow_store :touch_follower => true, :touch_followable => true
      end
      f = Foo.new
      assert f.methods.map {|x| x.to_s}.include?('belongs_to_touch_after_save_or_destroy_for_followable')
      assert f.methods.map {|x| x.to_s}.include?('belongs_to_touch_after_save_or_destroy_for_follower')
    end
  end

  context "Inherited models" do
    setup do
      @follower         = ImAFollower.create
      @followable       = ImAFollowable.create
      @follower_child   = ImAFollowerChild.create
      @followable_child = ImAFollowableChild.create
    end

    should "be able to follow a model inheriting from followable" do
      assert @follower.follow!(@followable_child)
      assert_true @follower.follows?(@followable_child)
    end

    should "be able to be followed by a model inheriting from follower" do
      assert @follower_child.follow!(@followable)
      assert_true @follower_child.follows?(@followable)
    end
  end

  def seed
    @follower1 = ImAFollower.create
    @follower2 = ImAFollower.create
    @followable1 = ImAFollowable.create
    @followable2 = ImAFollowable.create
  end
end
