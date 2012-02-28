require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class MentionTest < Test::Unit::TestCase
  context "a Mentioner" do
    setup do
      seed
    end

    should "be mentioner" do
      assert_equal true, @mentioner1.is_mentioner?
    end

    should "be able to mention a Mentionable" do
      assert @mentioner1.mention!(@mentionable1)
      assert_equal true, @mentioner1.mentions?(@mentionable1)
      assert_equal false, @mentioner2.mentions?(@mentionable1)
    end

    should "be able to unmention a Mentionable" do
      Mention.create :mentioner => @mentioner1, :mentionable => @mentionable1
      assert @mentioner1.unmention!(@mentionable1)
      assert_equal false, @mentioner1.mentions?(@mentionable1)
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
      @mentioner1.toggle_mention!(@mentionable1)
      assert_equal true, @mentioner1.mentions?(@mentionable1)
      @mentioner1.toggle_mention!(@mentionable1)
      assert_equal false, @mentioner1.mentions?(@mentionable1)
      @mentioner1.toggle_mention!(@mentionable1)
      assert_equal true, @mentioner1.mentions?(@mentionable1)
    end

    should "expose a list of its mentionees" do
      Mention.create :mentioner => @mentioner1, :mentionable => @mentionable1
      assert @mentioner1.mentionees(ImAMentioner).is_a?(ActiveRecord::Relation)
      assert_equal [@mentionable1], @mentioner1.mentionees(ImAMentionable).all

      assert_equal @mentioner1.mentionees(ImAMentionable), @mentioner1.mentionees(:im_a_mentionables)
      assert_equal @mentioner1.mentionees(ImAMentionable), @mentioner1.mentionees("im_a_mentionable")
    end
  end

  context "a Mentionable" do
    setup do
      seed
    end

    should "be mentionable" do
      assert_equal true, @mentionable1.is_mentionable?
    end

    should "be able to determine who mentions it" do
      Mention.create :mentioner => @mentioner1, :mentionable => @mentionable1
      assert_equal true, @mentionable1.mentioned_by?(@mentioner1)
      assert_equal false, @mentionable1.mentioned_by?(@mentioner2)
    end

    should "expose a list of its mentioners" do
      Mention.create :mentioner => @mentioner1, :mentionable => @mentionable1
      assert @mentionable1.mentioners(ImAMentioner).is_a?(ActiveRecord::Relation)
      assert_equal [@mentioner1], @mentionable1.mentioners(ImAMentioner).all

      assert_equal @mentionable1.mentioners(ImAMentioner), @mentionable1.mentioners(:im_a_mentioners)
      assert_equal @mentionable1.mentioners(ImAMentioner), @mentionable1.mentioners("im_a_mentioner")
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
      assert_equal false, @mentionable1.mentioned_by?(@mentioner1)
    end
  end

  context "Deleting a Mentionable" do
    setup do
      seed
      @mentioner1.mention!(@mentionable1)
    end

    should "delete its Mention records" do
      @mentionable1.destroy
      assert_equal false, @mentioner1.mentions?(@mentionable1)
    end
  end

  context "Single Table Inheritance" do
    setup do
      @mentioner = ImAMentioner.create
      @mentionable_child = ImAMentionableChild.create
    end

    should "be able to mention a model inheriting from mentionable" do
      assert @mentioner.mention!(@mentionable_child)
      assert_equal true, @mentioner.mentions?(@mentionable_child)
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
