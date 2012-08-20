require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class MentionerTest < Test::Unit::TestCase
  context "Mentioner" do
    setup do
      @mentioner = ImAMentioner.new
      @mentionable = ImAMentionable.create
    end

    context "#is_mentioner?" do
      should "return true" do
        assert_true @mentioner.is_mentioner?
      end
    end

    context "#mentioner?" do
      should "return true" do
        assert_true @mentioner.mentioner?
      end
    end

    context "#mention!" do
      should "not accept non-mentionables" do
        assert_raise(Socialization::ArgumentError) { @mentioner.mention!(:foo) }
      end

      should "call $Mention.mention!" do
        $Mention.expects(:mention!).with(@mentioner, @mentionable).once
        @mentioner.mention!(@mentionable)
      end
    end

    context "#unmention!" do
      should "not accept non-mentionables" do
        assert_raise(Socialization::ArgumentError) { @mentioner.unmention!(:foo) }
      end

      should "call $Mention.mention!" do
        $Mention.expects(:unmention!).with(@mentioner, @mentionable).once
        @mentioner.unmention!(@mentionable)
      end
    end

    context "#toggle_mention!" do
      should "not accept non-mentionables" do
        assert_raise(Socialization::ArgumentError) { @mentioner.unmention!(:foo) }
      end

      should "unmention when mentioning" do
        @mentioner.expects(:mentions?).with(@mentionable).once.returns(true)
        @mentioner.expects(:unmention!).with(@mentionable).once
        @mentioner.toggle_mention!(@mentionable)
      end

      should "mention when not mentioning" do
        @mentioner.expects(:mentions?).with(@mentionable).once.returns(false)
        @mentioner.expects(:mention!).with(@mentionable).once
        @mentioner.toggle_mention!(@mentionable)
      end
    end

    context "#mentions?" do
      should "not accept non-mentionables" do
        assert_raise(Socialization::ArgumentError) { @mentioner.unmention!(:foo) }
      end

      should "call $Mention.mentions?" do
        $Mention.expects(:mentions?).with(@mentioner, @mentionable).once
        @mentioner.mentions?(@mentionable)
      end
    end

    context "#mentionables" do
      should "call $Mention.mentionables" do
        $Mention.expects(:mentionables).with(@mentioner, @mentionable.class, { :foo => :bar })
        @mentioner.mentionables(@mentionable.class, { :foo => :bar })
      end
    end

    context "#mentionees" do
      should "call $Mention.mentionables" do
        $Mention.expects(:mentionables).with(@mentioner, @mentionable.class, { :foo => :bar })
        @mentioner.mentionees(@mentionable.class, { :foo => :bar })
      end
    end

    context "#mentionables_relation" do
      should "call $Mention.mentionables_relation" do
        $Mention.expects(:mentionables_relation).with(@mentioner, @mentionable.class, { :foo => :bar })
        @mentioner.mentionables_relation(@mentionable.class, { :foo => :bar })
      end
    end

    context "#mentionees_relation" do
      should "call $Mention.mentionables_relation" do
        $Mention.expects(:mentionables_relation).with(@mentioner, @mentionable.class, { :foo => :bar })
        @mentioner.mentionees_relation(@mentionable.class, { :foo => :bar })
      end
    end

    should "remove mention relationships" do
      Socialization.mention_model.expects(:remove_mentionables).with(@mentioner)
      @mentioner.destroy
    end
  end
end