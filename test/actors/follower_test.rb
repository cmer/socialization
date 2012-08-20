require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class FollowerTest < Test::Unit::TestCase
  context "Follower" do
    setup do
      @follower = ImAFollower.new
      @followable = ImAFollowable.create
    end

    context "#is_follower?" do
      should "return true" do
        assert_true @follower.is_follower?
      end
    end

    context "#follower?" do
      should "return true" do
        assert_true @follower.follower?
      end
    end

    context "#follow!" do
      should "not accept non-followables" do
        assert_raise(Socialization::ArgumentError) { @follower.follow!(:foo) }
      end

      should "call $Follow.follow!" do
        $Follow.expects(:follow!).with(@follower, @followable).once
        @follower.follow!(@followable)
      end
    end

    context "#unfollow!" do
      should "not accept non-followables" do
        assert_raise(Socialization::ArgumentError) { @follower.unfollow!(:foo) }
      end

      should "call $Follow.follow!" do
        $Follow.expects(:unfollow!).with(@follower, @followable).once
        @follower.unfollow!(@followable)
      end
    end

    context "#toggle_follow!" do
      should "not accept non-followables" do
        assert_raise(Socialization::ArgumentError) { @follower.unfollow!(:foo) }
      end

      should "unfollow when following" do
        @follower.expects(:follows?).with(@followable).once.returns(true)
        @follower.expects(:unfollow!).with(@followable).once
        @follower.toggle_follow!(@followable)
      end

      should "follow when not following" do
        @follower.expects(:follows?).with(@followable).once.returns(false)
        @follower.expects(:follow!).with(@followable).once
        @follower.toggle_follow!(@followable)
      end
    end

    context "#follows?" do
      should "not accept non-followables" do
        assert_raise(Socialization::ArgumentError) { @follower.unfollow!(:foo) }
      end

      should "call $Follow.follows?" do
        $Follow.expects(:follows?).with(@follower, @followable).once
        @follower.follows?(@followable)
      end
    end

    context "#followables" do
      should "call $Follow.followables" do
        $Follow.expects(:followables).with(@follower, @followable.class, { :foo => :bar })
        @follower.followables(@followable.class, { :foo => :bar })
      end
    end

    context "#followees" do
      should "call $Follow.followables" do
        $Follow.expects(:followables).with(@follower, @followable.class, { :foo => :bar })
        @follower.followees(@followable.class, { :foo => :bar })
      end
    end

    context "#followables_relation" do
      should "call $Follow.followables_relation" do
        $Follow.expects(:followables_relation).with(@follower, @followable.class, { :foo => :bar })
        @follower.followables_relation(@followable.class, { :foo => :bar })
      end
    end

    context "#followees_relation" do
      should "call $Follow.followables_relation" do
        $Follow.expects(:followables_relation).with(@follower, @followable.class, { :foo => :bar })
        @follower.followees_relation(@followable.class, { :foo => :bar })
      end
    end

    context "deleting a follower" do
      setup do
        @follower = ImAFollower.create
        @follower.follow!(@followable)
      end

      should "remove follow relationships" do
        Socialization.follow_model.expects(:remove_followables).with(@follower)
        @follower.destroy
      end
    end

  end
end