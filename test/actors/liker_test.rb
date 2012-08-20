require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class LikerTest < Test::Unit::TestCase
  context "Liker" do
    setup do
      @liker = ImALiker.new
      @likeable = ImALikeable.create
    end

    context "#is_liker?" do
      should "return true" do
        assert_true @liker.is_liker?
      end
    end

    context "#liker?" do
      should "return true" do
        assert_true @liker.liker?
      end
    end

    context "#like!" do
      should "not accept non-likeables" do
        assert_raise(Socialization::ArgumentError) { @liker.like!(:foo) }
      end

      should "call $Like.like!" do
        $Like.expects(:like!).with(@liker, @likeable).once
        @liker.like!(@likeable)
      end
    end

    context "#unlike!" do
      should "not accept non-likeables" do
        assert_raise(Socialization::ArgumentError) { @liker.unlike!(:foo) }
      end

      should "call $Like.like!" do
        $Like.expects(:unlike!).with(@liker, @likeable).once
        @liker.unlike!(@likeable)
      end
    end

    context "#toggle_like!" do
      should "not accept non-likeables" do
        assert_raise(Socialization::ArgumentError) { @liker.unlike!(:foo) }
      end

      should "unlike when likeing" do
        @liker.expects(:likes?).with(@likeable).once.returns(true)
        @liker.expects(:unlike!).with(@likeable).once
        @liker.toggle_like!(@likeable)
      end

      should "like when not likeing" do
        @liker.expects(:likes?).with(@likeable).once.returns(false)
        @liker.expects(:like!).with(@likeable).once
        @liker.toggle_like!(@likeable)
      end
    end

    context "#likes?" do
      should "not accept non-likeables" do
        assert_raise(Socialization::ArgumentError) { @liker.unlike!(:foo) }
      end

      should "call $Like.likes?" do
        $Like.expects(:likes?).with(@liker, @likeable).once
        @liker.likes?(@likeable)
      end
    end

    context "#likeables" do
      should "call $Like.likeables" do
        $Like.expects(:likeables).with(@liker, @likeable.class, { :foo => :bar })
        @liker.likeables(@likeable.class, { :foo => :bar })
      end
    end

    context "#likees" do
      should "call $Like.likeables" do
        $Like.expects(:likeables).with(@liker, @likeable.class, { :foo => :bar })
        @liker.likees(@likeable.class, { :foo => :bar })
      end
    end

    context "#likeables_relation" do
      should "call $Follow.likeables_relation" do
        $Like.expects(:likeables_relation).with(@liker, @likeable.class, { :foo => :bar })
        @liker.likeables_relation(@likeable.class, { :foo => :bar })
      end
    end

    context "#likees_relation" do
      should "call $Follow.likeables_relation" do
        $Like.expects(:likeables_relation).with(@liker, @likeable.class, { :foo => :bar })
        @liker.likees_relation(@likeable.class, { :foo => :bar })
      end
    end

    should "remove like relationships" do
      Socialization.like_model.expects(:remove_likeables).with(@liker)
      @liker.destroy
    end
  end
end