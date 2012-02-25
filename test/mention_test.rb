require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class MentionTest < Test::Unit::TestCase
  context "a Mentionner" do
    setup do
      seed
    end

    should "be mentionner" do
      assert_equal true, @mentionner1.is_mentionner?
    end

    should "be able to mention a Mentionable" do
      assert @mentionner1.mention!(@mentionable1)
      assert_equal true, @mentionner1.mentions?(@mentionable1)
      assert_equal false, @mentionner2.mentions?(@mentionable1)
    end

    should "be able to unmention a Mentionable" do
      Mention.create :mentionner => @mentionner1, :mentionable => @mentionable1
      assert @mentionner1.unmention!(@mentionable1)
      assert_equal false, @mentionner1.mentions?(@mentionable1)
    end

    should "not be able to mention the same thing twice" do
      assert @mentionner1.mention!(@mentionable1)

      assert_raise ActiveRecord::RecordInvalid do
        @mentionner1.mention!(@mentionable1)
      end
    end

    should "not be able to unmention something that is not mentionned" do
      assert_raise ActiveRecord::RecordNotFound do
        @mentionner1.unmention!(@mentionable1)
      end
    end

    should "be able to mention itself" do
      @mentionner_and_mentionable.mention!(@mentionner_and_mentionable)
    end

    should "expose a list of its mentionees" do
      Mention.create :mentionner => @mentionner1, :mentionable => @mentionable1
      assert @mentionner1.mentionees(ImAMentionner).is_a?(ActiveRecord::Relation)
      assert_equal [@mentionable1], @mentionner1.mentionees(ImAMentionable).all

      assert_equal @mentionner1.mentionees(ImAMentionable), @mentionner1.mentionees(:im_a_mentionables)
      assert_equal @mentionner1.mentionees(ImAMentionable), @mentionner1.mentionees("im_a_mentionable")
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
      Mention.create :mentionner => @mentionner1, :mentionable => @mentionable1
      assert_equal true, @mentionable1.mentioned_by?(@mentionner1)
      assert_equal false, @mentionable1.mentioned_by?(@mentionner2)
    end

    should "expose a list of its mentionners" do
      Mention.create :mentionner => @mentionner1, :mentionable => @mentionable1
      assert @mentionable1.mentionners(ImAMentionner).is_a?(ActiveRecord::Relation)
      assert_equal [@mentionner1], @mentionable1.mentionners(ImAMentionner).all

      assert_equal @mentionable1.mentionners(ImAMentionner), @mentionable1.mentionners(:im_a_mentionners)
      assert_equal @mentionable1.mentionners(ImAMentionner), @mentionable1.mentionners("im_a_mentionner")
    end

    should "expose mentionings" do
      Mention.create :mentionner => @mentionner1, :mentionable => @mentionable1
      mentionings = @mentionable1.mentionings
      assert_equal 1, mentionings.size
      assert mentionings.first.is_a?(Mention)
    end
  end

  context "Deleting a mentionner" do
    setup do
      seed
      @mentionner1.mention!(@mentionable1)
    end

    should "delete its Mention records" do
      @mentionner1.destroy
      assert_equal false, @mentionable1.mentioned_by?(@mentionner1)
    end
  end

  context "Deleting a Mentionable" do
    setup do
      seed
      @mentionner1.mention!(@mentionable1)
    end

    should "delete its Mention records" do
      @mentionable1.destroy
      assert_equal false, @mentionner1.mentions?(@mentionable1)
    end
  end

  def seed
    @mentionner1 = ImAMentionner.create
    @mentionner2 = ImAMentionner.create
    @mentionable1 = ImAMentionable.create
    @mentionable2 = ImAMentionable.create
    @mentionner_and_mentionable = ImAMentionnerAndMentionable.create
  end
end
