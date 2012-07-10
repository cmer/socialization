require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'

class ActiveRecordFollowStoreTest < Test::Unit::TestCase
  context "ActiveRecordStores::FollowStoreTest" do
    setup do
      @klass = Socialization::ActiveRecordStores::Follow
      @klass.touch nil
      @klass.after_follow nil
      @klass.after_unfollow nil
      @follower = ImAFollower.create
      @followable = ImAFollowable.create
    end

    context "data store" do
      should "inherit Socialization::ActiveRecordStores::Follow" do
        assert_equal Socialization::ActiveRecordStores::Follow, Socialization.follow_model
      end
    end

    context "#follow!" do
      should "create a Follow record" do
        @klass.follow!(@follower, @followable)
        assert_match_follower @klass.last, @follower
        assert_match_followable @klass.last, @followable
      end

      should "touch follower when instructed" do
        @klass.touch :follower
        @follower.expects(:touch).once
        @followable.expects(:touch).never
        @klass.follow!(@follower, @followable)
      end

      should "touch followable when instructed" do
        @klass.touch :followable
        @follower.expects(:touch).never
        @followable.expects(:touch).once
        @klass.follow!(@follower, @followable)
      end

      should "touch all when instructed" do
        @klass.touch :all
        @follower.expects(:touch).once
        @followable.expects(:touch).once
        @klass.follow!(@follower, @followable)
      end

      should "call after follow hook" do
        @klass.after_follow :after_follow
        @klass.expects(:after_follow).once
        @klass.follow!(@follower, @followable)
      end

      should "call after unfollow hook" do
        @klass.after_follow :after_unfollow
        @klass.expects(:after_unfollow).once
        @klass.follow!(@follower, @followable)
      end
    end

    context "#follows?" do
      should "return true when follow exists" do
        @klass.create! do |f|
          f.follower = @follower
          f.followable = @followable
        end
        assert_true @klass.follows?(@follower, @followable)
      end

      should "return false when follow doesn't exist" do
        assert_false @klass.follows?(@follower, @followable)
      end
    end

    context "#followers" do
      should "return an array of followers" do
        follower1 = ImAFollower.create
        follower2 = ImAFollower.create
        follower1.follow!(@followable)
        follower2.follow!(@followable)
        assert_equal [follower1, follower2], @klass.followers(@followable, follower1.class)
      end

      should "return an array of follower ids when plucking" do
        follower1 = ImAFollower.create
        follower2 = ImAFollower.create
        follower1.follow!(@followable)
        follower2.follow!(@followable)
        assert_equal [follower1.id, follower2.id], @klass.followers(@followable, follower1.class, :pluck => :id)
      end
    end

    context "#followables" do
      should "return an array of followers" do
        followable1 = ImAFollowable.create
        followable2 = ImAFollowable.create
        @follower.follow!(followable1)
        @follower.follow!(followable2)
        assert_equal [followable1, followable2], @klass.followables(@follower, followable1.class)
      end

      should "return an array of follower ids when plucking" do
        followable1 = ImAFollowable.create
        followable2 = ImAFollowable.create
        @follower.follow!(followable1)
        @follower.follow!(followable2)
        assert_equal [followable1.id, followable2.id], @klass.followables(@follower, followable1.class, :pluck => :id)
      end
    end

    context "#remove_followers" do
      should "delete all followers relationships for a followable" do
        @follower.follow!(@followable)
        assert_equal 1, @followable.followers(@follower.class).count
        @klass.remove_followers(@followable)
        assert_equal 0, @followable.followers(@follower.class).count
      end
    end

    context "#remove_followables" do
      should "delete all followables relationships for a follower" do
        @follower.follow!(@followable)
        assert_equal 1, @follower.followables(@followable.class).count
        @klass.remove_followables(@follower)
        assert_equal 0, @follower.followables(@followable.class).count
      end
    end
  end

  # Helpers
  def assert_match_follower(follow_record, follower)
    assert follow_record.follower_type ==  follower.class.to_s && follow_record.follower_id == follower.id
  end

  def assert_match_followable(follow_record, followable)
    assert follow_record.followable_type ==  followable.class.to_s && follow_record.followable_id == followable.id
  end
end
