require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class LikeTest < Test::Unit::TestCase
  context "a Liker" do
    setup do
      seed
    end

    should "be liker" do
      assert_true  @liker1.is_liker?
    end

    should "be able to like a Likeable" do
      assert @liker1.like!(@likeable1)
      assert_true  @liker1.likes?(@likeable1)
      assert_false @liker2.likes?(@likeable1)
    end

    should "be able to unlike a Likeable" do
      Like.create :liker => @liker1, :likeable => @likeable1
      assert @liker1.unlike!(@likeable1)
      assert_false @liker1.likes?(@likeable1)
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

    should "be able to toggle likes on/off" do
      assert_false @liker1.likes?(@likeable1)
      assert_true  @liker1.toggle_like!(@likeable1)
      assert_true  @liker1.likes?(@likeable1)
      assert_false @liker1.toggle_like!(@likeable1)
      assert_false @liker1.likes?(@likeable1)
      assert_true  @liker1.toggle_like!(@likeable1)
      assert_true  @liker1.likes?(@likeable1)
    end

    should "expose a list of its likes" do
      Like.create :liker => @liker1, :likeable => @likeable1
      assert @liker1.likees(ImALikeable).is_a?(ActiveRecord::Relation)
      assert_equal [@likeable1], @liker1.likees(ImALikeable).all

      assert_equal @liker1.likees(ImALikeable), @liker1.likees(:im_a_likeables)
      assert_equal @liker1.likees(ImALikeable), @liker1.likees("im_a_likeable")
    end
  end

  context "a Likeable" do
    setup do
      seed
    end

    should "be likeable" do
      assert_true  @likeable1.is_likeable?
    end

    should "be able to determine who likes it" do
      Like.create :liker => @liker1, :likeable => @likeable1
      assert_true  @likeable1.liked_by?(@liker1)
      assert_false @likeable1.liked_by?(@liker2)
    end

    should "expose a list of its likers" do
      Like.create :liker => @liker1, :likeable => @likeable1
      assert @likeable1.likers(ImALiker).is_a?(ActiveRecord::Relation)
      assert_equal [@liker1], @likeable1.likers(ImALiker).all

      assert_equal @likeable1.likers(ImALiker), @likeable1.likers(:im_a_likers)
      assert_equal @likeable1.likers(ImALiker), @likeable1.likers("im_a_liker")
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
      assert_false @likeable1.liked_by?(@liker1)
    end
  end

  context "Deleting a Likeable" do
    setup do
      seed
      @liker1.like!(@likeable1)
    end

    should "delete its Like records" do
      @likeable1.destroy
      assert_false @liker1.likes?(@likeable1)
    end
  end

  context "Virgin ActiveRecord::Base objects" do
    setup do
      @foo = Vanilla.new
    end

    should "not be liker" do
      assert_false @foo.is_liker?
    end

    should "not be likeable" do
      assert_false @foo.is_likeable?
    end
  end

  context "acts_as_like_store" do
    should "touch associated record when touch_liker and/or touch_likeable are set" do
      class Foo < ActiveRecord::Base
        self.table_name = 'likes'; acts_as_like_store touch_liker: true, touch_likeable: true
      end
      f = Foo.new
      assert f.methods.include?(:belongs_to_touch_after_save_or_destroy_for_likeable)
      assert f.methods.include?(:belongs_to_touch_after_save_or_destroy_for_liker)
    end
  end

  context "Inherited models" do
    setup do
      @liker          = ImALiker.create
      @likeable       = ImALikeable.create
      @liker_child    = ImALikerChild.create
      @likeable_child = ImALikeableChild.create
    end

    should "be able to like a model inheriting from a Likeable" do
      assert @liker.like!(@likeable_child)
      assert_true @liker.likes?(@likeable_child)
    end

    should "be able to be liked by a model inheriting from liker" do
      assert @liker_child.like!(@likeable)
      assert_true @liker_child.likes?(@likeable)
    end
  end

  def seed
    @liker1 = ImALiker.create
    @liker2 = ImALiker.create
    @likeable1 = ImALikeable.create
    @likeable2 = ImALikeable.create
  end
end
