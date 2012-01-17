require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class LikeTest < Test::Unit::TestCase
  context "a Liker" do
    setup do
      seed
    end

    should "respond to is_liker?" do
      assert_equal true, @liker1.respond_to?(:is_liker?)
      assert_equal true, @liker1.is_liker?
    end

    should "be able to like a Likeable" do
      assert @liker1.like!(@likeable1)
      assert_equal true, @liker1.likes?(@likeable1)
      assert_equal false, @liker2.likes?(@likeable1)
    end

    should "be able to unlike a Likeable" do
      Like.create :liker => @liker1, :likeable => @likeable1
      assert @liker1.unlike!(@likeable1)
      assert_equal false, @liker1.likes?(@likeable1)
    end

    should "not be able to like the same thing twice" do
      assert @liker1.like!(@likeable1)

      assert_raise ActiveRecord::RecordInvalid do
        @liker1.like!(@likeable1)
      end
    end

    should "not be able to unlike something that is not liked" do
      assert_raise ActiveRecord::RecordNotFound do
        @liker1.unlike!(@likeable1)
      end
    end
  end

  context "a Likeable" do
    setup do
      seed
    end

    should "respond to is_likeable?" do
      assert_equal true, @likeable1.respond_to?(:is_likeable?)
      assert_equal true, @likeable1.is_likeable?
    end

    should "be able to determine who likes it" do
      Like.create :liker => @liker1, :likeable => @likeable1
      assert_equal true, @likeable1.liked_by?(@liker1)
      assert_equal false, @likeable1.liked_by?(@liker2)
    end

    should "expose a list of its likers" do
      Like.create :liker => @liker1, :likeable => @likeable1
      assert_equal [@liker1], @likeable1.likers
    end

    should "expose likings" do
      Like.create :liker => @liker1, :likeable => @likeable1
      likings = @likeable1.likings
      assert_equal 1, likings.size
      assert likings.first.is_a?(Like)
    end
  end

  context "Deleting a Liker" do
    setup do
      seed
      @liker1.like!(@likeable1)
    end

    should "delete its Like records" do
      @liker1.destroy
      assert_equal false, @likeable1.liked_by?(@liker1)
    end
  end

  context "Deleting a Likeable" do
    setup do
      seed
      @liker1.like!(@likeable1)
    end

    should "delete its Like records" do
      @likeable1.destroy
      assert_equal false, @liker1.likes?(@likeable1)
    end
  end

  def seed
    @liker1 = ImALiker.create
    @liker2 = ImALiker.create
    @likeable1 = ImALikeable.create
    @likeable2 = ImALikeable.create
  end
end
