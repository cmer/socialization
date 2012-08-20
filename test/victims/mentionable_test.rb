require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class MentionableTest < Test::Unit::TestCase
  context "Mentionable" do
    setup do
      @mentioner = ImAMentioner.new
      @mentionable = ImAMentionable.create
    end

    context "#is_mentionable?" do
      should "return true" do
        assert_true @mentionable.is_mentionable?
      end
    end

    context "#mentionable?" do
      should "return true" do
        assert_true @mentionable.mentionable?
      end
    end

    context "#mentioned_by?" do
      should "not accept non-mentioners" do
        assert_raise(Socialization::ArgumentError) { @mentionable.mentioned_by?(:foo) }
      end

      should "call $Mention.mentions?" do
        $Mention.expects(:mentions?).with(@mentioner, @mentionable).once
        @mentionable.mentioned_by?(@mentioner)
      end
    end

    context "#mentioners" do
      should "call $Mention.mentioners" do
        $Mention.expects(:mentioners).with(@mentionable, @mentioner.class, { :foo => :bar })
        @mentionable.mentioners(@mentioner.class, { :foo => :bar })
      end
    end

    context "#mentioners_relation" do
      should "call $Mention.mentioners" do
        $Mention.expects(:mentioners_relation).with(@mentionable, @mentioner.class, { :foo => :bar })
        @mentionable.mentioners_relation(@mentioner.class, { :foo => :bar })
      end
    end

    context "deleting a mentionable" do
      setup do
        @mentioner = ImAMentioner.create
        @mentioner.mention!(@mentionable)
      end

      should "remove mention relationships" do
        Socialization.mention_model.expects(:remove_mentioners).with(@mentionable)
        @mentionable.destroy
      end
    end

  end
end