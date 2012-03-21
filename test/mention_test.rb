require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class MentionTest < Test::Unit::TestCase
  context "a Mentioner" do
    setup do
      seed
    end

    should "be mentioner" do
      assert_true  @mentioner1.is_mentioner?
    end

    should "be able to mention a Mentionable" do
      assert @mentioner1.mention!(@mentionable1)
      assert_true  @mentioner1.mentions?(@mentionable1)
      assert_false @mentioner2.mentions?(@mentionable1)
    end

    should "be able to unmention a Mentionable" do
      Mention.create :mentioner => @mentioner1, :mentionable => @mentionable1
      assert @mentioner1.unmention!(@mentionable1)
      assert_false @mentioner1.mentions?(@mentionable1)
    end

    should "not be able to mention the same thing twice" do
      assert @mentioner1.mention!(@mentionable1)

      assert_raise ActiveRecord::RecordInvalid do
        @mentioner1.mention!(@mentionable1)
      end
    end

    should "not be able to unmention something that is not mentionned" do
      assert_raise ActiveRecord::RecordNotFound do
        @mentioner1.unmention!(@mentionable1)
      end
    end

    should "be able to mention itself" do
      @mentioner_and_mentionable.mention!(@mentioner_and_mentionable)
    end

    should "be able to toggle mentions on/off" do
      assert_false @mentioner1.mentions?(@mentionable1)
      assert_true  @mentioner1.toggle_mention!(@mentionable1)
      assert_true  @mentioner1.mentions?(@mentionable1)
      assert_false @mentioner1.toggle_mention!(@mentionable1)
      assert_false @mentioner1.mentions?(@mentionable1)
      assert_true  @mentioner1.toggle_mention!(@mentionable1)
      assert_true  @mentioner1.mentions?(@mentionable1)
    end

    should "expose a list of its mentionees" do
      Mention.create :mentioner => @mentioner1, :mentionable => @mentionable1
      assert @mentioner1.mentionees(ImAMentioner).is_a?(ActiveRecord::Relation)
      assert_equal [@mentionable1], @mentioner1.mentionees(ImAMentionable).all

      assert_equal @mentioner1.mentionees(ImAMentionable), @mentioner1.mentionees(:im_a_mentionables)
      assert_equal @mentioner1.mentionees(ImAMentionable), @mentioner1.mentionees("im_a_mentionable")
    end

    should "expose a shortcut method for its mentionees" do
      Mention.create :mentioner => @mentioner1, :mentionable => @mentionable1

      assert @mentioner1.respond_to?(:im_a_mentionable_mentionees)
      assert_equal @mentioner1.mentionees(ImAMentionable), @mentioner1.im_a_mentionable_mentionees
    end
  end

  context "a Mentionable" do
    setup do
      seed
    end

    should "be mentionable" do
      assert_true  @mentionable1.is_mentionable?
    end

    should "be able to determine who mentions it" do
      Mention.create :mentioner => @mentioner1, :mentionable => @mentionable1
      assert_true  @mentionable1.mentioned_by?(@mentioner1)
      assert_false @mentionable1.mentioned_by?(@mentioner2)
    end

    should "expose a list of its mentioners" do
      Mention.create :mentioner => @mentioner1, :mentionable => @mentionable1
      assert @mentionable1.mentioners(ImAMentioner).is_a?(ActiveRecord::Relation)
      assert_equal [@mentioner1], @mentionable1.mentioners(ImAMentioner).all

      assert_equal @mentionable1.mentioners(ImAMentioner), @mentionable1.mentioners(:im_a_mentioners)
      assert_equal @mentionable1.mentioners(ImAMentioner), @mentionable1.mentioners("im_a_mentioner")
    end

    should "expose a shortcut method for its mentioners" do
      Mention.create :mentioner => @mentioner1, :mentionable => @mentionable1

      assert @mentionable1.respond_to?(:im_a_mentioner_mentioners)
      assert_equal @mentionable1.mentioners(ImAMentioner), @mentionable1.im_a_mentioner_mentioners
    end

    should "expose mentionings" do
      Mention.create :mentioner => @mentioner1, :mentionable => @mentionable1
      mentionings = @mentionable1.mentionings
      assert_equal 1, mentionings.size
      assert mentionings.first.is_a?(Mention)
    end
  end

  context "Deleting a mentioner" do
    setup do
      seed
      @mentioner1.mention!(@mentionable1)
    end

    should "delete its Mention records" do
      @mentioner1.destroy
      assert_false @mentionable1.mentioned_by?(@mentioner1)
    end
  end

  context "Deleting a Mentionable" do
    setup do
      seed
      @mentioner1.mention!(@mentionable1)
    end

    should "delete its Mention records" do
      @mentionable1.destroy
      assert_false @mentioner1.mentions?(@mentionable1)
    end
  end

  context "Virgin ActiveRecord::Base objects" do
    setup do
      @foo = Vanilla.new
    end

    should "not be mentioner" do
      assert_false @foo.is_mentioner?
    end

    should "not be mentionable" do
      assert_false @foo.is_mentionable?
    end
  end

  context "acts_as_mention_store" do
    should "touch associated record when touch_mentioner and/or touch_mentionable are set" do
      class Foo < ActiveRecord::Base
        self.table_name = 'mentions'; acts_as_mention_store :touch_mentioner => true, :touch_mentionable => true
      end
      f = Foo.new
      assert f.methods.map {|x| x.to_s}.include?('belongs_to_touch_after_save_or_destroy_for_mentionable')
      assert f.methods.map {|x| x.to_s}.include?('belongs_to_touch_after_save_or_destroy_for_mentioner')
    end
  end

  context "Single Table Inheritance" do
    setup do
      @mentioner         = ImAMentioner.create
      @mentioner_child   = ImAMentionerChild.create
      @mentionable       = ImAMentionable.create
      @mentionable_child = ImAMentionableChild.create
    end

    should "be able to mention a model inheriting from mentionable" do
      assert @mentioner.mention!(@mentionable_child)
      assert_true @mentioner.mentions?(@mentionable_child)
    end

    should "be able to be mentioned by a model inheriting from mentioner" do
      assert @mentioner_child.mention!(@mentionable)
      assert_true @mentioner_child.mentions?(@mentionable)
    end
  end

  def seed
    @mentioner1 = ImAMentioner.create
    @mentioner2 = ImAMentioner.create
    @mentionable1 = ImAMentionable.create
    @mentionable2 = ImAMentionable.create
    @mentioner_and_mentionable = ImAMentionerAndMentionable.create
  end
end
