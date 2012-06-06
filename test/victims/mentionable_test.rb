require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class MentionableTest < Test::Unit::TestCase
  context "Mentionable" do
    setup do
      @mentioner = ImAMentioner.new
      @mentionable = ImAMentionable.create
    end

    context "#is_mentionable" do
      should "return true" do
        assert_true @mentionable.is_mentionable?
      end
    end

    context "#mentioned_by?" do
      should "not accept non-mentioners" do
        assert_raise(ArgumentError) { @mentionable.mentioned_by?(:foo) }
      end

      should "call $Mention.mentions?" do
        $Mention.expects(:mentions?).with(@mentioner, @mentionable).once
        @mentionable.mentioned_by?(@mentioner)
      end
    end

    context "#mentioners" do
      should "call $Mentionmentioners" do
        $Mention.expects(:mentioners).with(@mentionable, @mentioner.class, { :foo => :bar })
        @mentionable.mentioners(@mentioner.class, { :foo => :bar })
      end
    end
  end
end