require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class FollowableTest < Test::Unit::TestCase
  context "Followable" do
    setup do
      @follower = ImAFollower.new
      @followable = ImAFollowable.create
    end

    context "#is_followable" do
      should "return true" do
        assert_true @followable.is_followable?
      end
    end

    context "#followed_by?" do
      should "not accept non-followers" do
        assert_raise(ArgumentError) { @followable.followed_by?(:foo) }
      end

      should "call $Follow.follows?" do
        $Follow.expects(:follows?).with(@follower, @followable).once
        @followable.followed_by?(@follower)
      end
    end

    context "#followers" do
      should "call $Follow.followers" do
        $Follow.expects(:followers).with(@followable, @follower.class, { :foo => :bar })
        @followable.followers(@follower.class, { :foo => :bar })
      end
    end

    context "#followers_relation" do
      should "call $Follow.followers_relation" do
        $Follow.expects(:followers_relation).with(@followable, @follower.class, { :foo => :bar })
        @followable.followers_relation(@follower.class, { :foo => :bar })
      end
    end

  end
end