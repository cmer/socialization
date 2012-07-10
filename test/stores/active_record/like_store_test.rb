require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'

class ActiveRecordLikeStoreTest < Test::Unit::TestCase
  context "ActiveRecordStores::LikeStoreTest" do
    setup do
      @klass = Socialization::ActiveRecordStores::Like
      @klass.touch nil
      @klass.after_like nil
      @klass.after_unlike nil
      @liker = ImALiker.create
      @likeable = ImALikeable.create
    end

    context "data store" do
      should "inherit Socialization::ActiveRecordStores::Like" do
        assert_equal Socialization::ActiveRecordStores::Like, Socialization.like_model
      end
    end

    context "#like!" do
      should "create a Like record" do
        @klass.like!(@liker, @likeable)
        assert_match_liker @klass.last, @liker
        assert_match_likeable @klass.last, @likeable
      end

      should "touch liker when instructed" do
        @klass.touch :liker
        @liker.expects(:touch).once
        @likeable.expects(:touch).never
        @klass.like!(@liker, @likeable)
      end

      should "touch likeable when instructed" do
        @klass.touch :likeable
        @liker.expects(:touch).never
        @likeable.expects(:touch).once
        @klass.like!(@liker, @likeable)
      end

      should "touch all when instructed" do
        @klass.touch :all
        @liker.expects(:touch).once
        @likeable.expects(:touch).once
        @klass.like!(@liker, @likeable)
      end

      should "call after like hook" do
        @klass.after_like :after_like
        @klass.expects(:after_like).once
        @klass.like!(@liker, @likeable)
      end

      should "call after unlike hook" do
        @klass.after_like :after_unlike
        @klass.expects(:after_unlike).once
        @klass.like!(@liker, @likeable)
      end
    end

    context "#likes?" do
      should "return true when like exists" do
        @klass.create! do |f|
          f.liker = @liker
          f.likeable = @likeable
        end
        assert_true @klass.likes?(@liker, @likeable)
      end

      should "return false when like doesn't exist" do
        assert_false @klass.likes?(@liker, @likeable)
      end
    end

    context "#likers" do
      should "return an array of likers" do
        liker1 = ImALiker.create
        liker2 = ImALiker.create
        liker1.like!(@likeable)
        liker2.like!(@likeable)
        assert_equal [liker1, liker2], @klass.likers(@likeable, liker1.class)
      end

      should "return an array of liker ids when plucking" do
        liker1 = ImALiker.create
        liker2 = ImALiker.create
        liker1.like!(@likeable)
        liker2.like!(@likeable)
        assert_equal [liker1.id, liker2.id], @klass.likers(@likeable, liker1.class, :pluck => :id)
      end
    end

    context "#likeables" do
      should "return an array of likers" do
        likeable1 = ImALikeable.create
        likeable2 = ImALikeable.create
        @liker.like!(likeable1)
        @liker.like!(likeable2)
        assert_equal [likeable1, likeable2], @klass.likeables(@liker, likeable1.class)
      end

      should "return an array of liker ids when plucking" do
        likeable1 = ImALikeable.create
        likeable2 = ImALikeable.create
        @liker.like!(likeable1)
        @liker.like!(likeable2)
        assert_equal [likeable1.id, likeable2.id], @klass.likeables(@liker, likeable1.class, :pluck => :id)
      end
    end

    context "#remove_likers" do
      should "delete all likers relationships for a likeable" do
        @liker.like!(@likeable)
        assert_equal 1, @likeable.likers(@liker.class).count
        @klass.remove_likers(@likeable)
        assert_equal 0, @likeable.likers(@liker.class).count
      end
    end

    context "#remove_likeables" do
      should "delete all likeables relationships for a liker" do
        @liker.like!(@likeable)
        assert_equal 1, @liker.likeables(@likeable.class).count
        @klass.remove_likeables(@liker)
        assert_equal 0, @liker.likeables(@likeable.class).count
      end
    end

  end

  # Helpers
  def assert_match_liker(like_record, liker)
    assert like_record.liker_type ==  liker.class.to_s && like_record.liker_id == liker.id
  end

  def assert_match_likeable(like_record, likeable)
    assert like_record.likeable_type ==  likeable.class.to_s && like_record.likeable_id == likeable.id
  end
end
