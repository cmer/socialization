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
      assert_equal [@mentionner1], @mentionable1.mentionners
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
  end
end