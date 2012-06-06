require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class LikeableTest < Test::Unit::TestCase
  context "Likeable" do
    setup do
      @liker = ImALiker.new
      @likeable = ImALikeable.create
    end

    context "#is_likeable" do
      should "return true" do
        assert_true @likeable.is_likeable?
      end
    end

    context "#liked_by?" do
      should "not accept non-likers" do
        assert_raise(ArgumentError) { @likeable.liked_by?(:foo) }
      end

      should "call $Like.likes?" do
        $Like.expects(:likes?).with(@liker, @likeable).once
        @likeable.liked_by?(@liker)
      end
    end

    context "#likers" do
      should "call $Like.likers" do
        $Like.expects(:likers).with(@likeable, @liker.class, { :foo => :bar })
        @likeable.likers(@liker.class, { :foo => :bar })
      end
    end
  end
end