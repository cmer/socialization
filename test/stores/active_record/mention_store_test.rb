require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'

class ActiveRecordMentionStoreTest < Test::Unit::TestCase
  context "ActiveRecordStores::MentionStoreTest" do
    setup do
      @klass = Socialization::ActiveRecordStores::Mention
      @klass.touch nil
      @klass.after_mention nil
      @klass.after_unmention nil
      @mentioner = ImAMentioner.create
      @mentionable = ImAMentionable.create
    end

    context "data store" do
      should "inherit Socialization::ActiveRecordStores::Mention" do
        assert_equal Socialization::ActiveRecordStores::Mention, Socialization.mention_model
      end
    end

    context "#mention!" do
      should "create a Mention record" do
        @klass.mention!(@mentioner, @mentionable)
        assert_match_mentioner @klass.last, @mentioner
        assert_match_mentionable @klass.last, @mentionable
      end

      should "touch mentioner when instructed" do
        @klass.touch :mentioner
        @mentioner.expects(:touch).once
        @mentionable.expects(:touch).never
        @klass.mention!(@mentioner, @mentionable)
      end

      should "touch mentionable when instructed" do
        @klass.touch :mentionable
        @mentioner.expects(:touch).never
        @mentionable.expects(:touch).once
        @klass.mention!(@mentioner, @mentionable)
      end

      should "touch all when instructed" do
        @klass.touch :all
        @mentioner.expects(:touch).once
        @mentionable.expects(:touch).once
        @klass.mention!(@mentioner, @mentionable)
      end

      should "call after mention hook" do
        @klass.after_mention :after_mention
        @klass.expects(:after_mention).once
        @klass.mention!(@mentioner, @mentionable)
      end

      should "call after unmention hook" do
        @klass.after_mention :after_unmention
        @klass.expects(:after_unmention).once
        @klass.mention!(@mentioner, @mentionable)
      end
    end

    context "#mentions?" do
      should "return true when mention exists" do
        @klass.create! do |f|
          f.mentioner = @mentioner
          f.mentionable = @mentionable
        end
        assert_true @klass.mentions?(@mentioner, @mentionable)
      end

      should "return false when mention doesn't exist" do
        assert_false @klass.mentions?(@mentioner, @mentionable)
      end
    end

    context "#mentioners" do
      should "return an array of mentioners" do
        mentioner1 = ImAMentioner.create
        mentioner2 = ImAMentioner.create
        mentioner1.mention!(@mentionable)
        mentioner2.mention!(@mentionable)
        assert_equal [mentioner1, mentioner2], @klass.mentioners(@mentionable, mentioner1.class)
      end

      should "return an array of mentioner ids when plucking" do
        mentioner1 = ImAMentioner.create
        mentioner2 = ImAMentioner.create
        mentioner1.mention!(@mentionable)
        mentioner2.mention!(@mentionable)
        assert_equal [mentioner1.id, mentioner2.id], @klass.mentioners(@mentionable, mentioner1.class, :pluck => :id)
      end
    end

    context "#mentionables" do
      should "return an array of mentioners" do
        mentionable1 = ImAMentionable.create
        mentionable2 = ImAMentionable.create
        @mentioner.mention!(mentionable1)
        @mentioner.mention!(mentionable2)
        assert_equal [mentionable1, mentionable2], @klass.mentionables(@mentioner, mentionable1.class)
      end

      should "return an array of mentioner ids when plucking" do
        mentionable1 = ImAMentionable.create
        mentionable2 = ImAMentionable.create
        @mentioner.mention!(mentionable1)
        @mentioner.mention!(mentionable2)
        assert_equal [mentionable1.id, mentionable2.id], @klass.mentionables(@mentioner, mentionable1.class, :pluck => :id)
      end
    end

    context "#remove_mentioners" do
      should "delete all mentioners relationships for a mentionable" do
        @mentioner.mention!(@mentionable)
        assert_equal 1, @mentionable.mentioners(@mentioner.class).count
        @klass.remove_mentioners(@mentionable)
        assert_equal 0, @mentionable.mentioners(@mentioner.class).count
      end
    end

    context "#remove_mentionables" do
      should "delete all mentionables relationships for a mentioner" do
        @mentioner.mention!(@mentionable)
        assert_equal 1, @mentioner.mentionables(@mentionable.class).count
        @klass.remove_mentionables(@mentioner)
        assert_equal 0, @mentioner.mentionables(@mentionable.class).count
      end
    end
  end

  # Helpers
  def assert_match_mentioner(mention_record, mentioner)
    assert mention_record.mentioner_type ==  mentioner.class.to_s && mention_record.mentioner_id == mentioner.id
  end

  def assert_match_mentionable(mention_record, mentionable)
    assert mention_record.mentionable_type ==  mentionable.class.to_s && mention_record.mentionable_id == mentionable.id
  end
end
