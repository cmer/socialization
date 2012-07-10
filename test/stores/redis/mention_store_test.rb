require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'

class RedisMentionStoreTest < Test::Unit::TestCase
  context "RedisStores::MentionStoreTest" do
    setup do
      use_redis_store
      @klass = Socialization::RedisStores::Mention
      @klass.touch nil
      @klass.after_mention nil
      @klass.after_unmention nil
      @mentioner = ImAMentioner.create
      @mentionable = ImAMentionable.create
    end

    context "Stores" do
      should "inherit Socialization::RedisStores::Mention" do
        assert_equal Socialization::RedisStores::Mention, Socialization.mention_model
      end
    end

    context "#mention!" do
      should "create a Mention record" do
        @klass.mention!(@mentioner, @mentionable)
        assert_equal ["#{@mentioner.id}"], Socialization.redis.smembers(mentioners_key(@mentioner, @mentionable))
        assert_equal ["#{@mentionable.id}"], Socialization.redis.smembers(mentionables_key(@mentioner, @mentionable))
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
        Socialization.redis.sadd mentioners_key(@mentioner, @mentionable), @mentioner.id
        Socialization.redis.sadd mentionables_key(@mentioner, @mentionable), @mentionable.id
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
        assert_array_similarity [mentioner1, mentioner2], @klass.mentioners(@mentionable, mentioner1.class)
      end

      should "return an array of mentioner ids when plucking" do
        mentioner1 = ImAMentioner.create
        mentioner2 = ImAMentioner.create
        mentioner1.mention!(@mentionable)
        mentioner2.mention!(@mentionable)
        assert_array_similarity [mentioner1.id, mentioner2.id], @klass.mentioners(@mentionable, mentioner1.class, :pluck => :id)
      end
    end

    context "#mentionables" do
      should "return an array of mentionables" do
        mentionable1 = ImAMentionable.create
        mentionable2 = ImAMentionable.create
        @mentioner.mention!(mentionable1)
        @mentioner.mention!(mentionable2)

        assert_array_similarity [mentionable1, mentionable2], @klass.mentionables(@mentioner, mentionable1.class)
      end

      should "return an array of mentionables ids when plucking" do
        mentionable1 = ImAMentionable.create
        mentionable2 = ImAMentionable.create
        @mentioner.mention!(mentionable1)
        @mentioner.mention!(mentionable2)
        assert_array_similarity [mentionable1.id, mentionable2.id], @klass.mentionables(@mentioner, mentionable1.class, :pluck => :id)
      end
    end

    context "#generate_mentioners_key" do
      should "return valid key when passed objects" do
        assert_equal "Mentioners:ImAMentionable:#{@mentionable.id}:ImAMentioner", mentioners_key(@mentioner, @mentionable)
      end

      should "return valid key when mentioner is a class" do
        assert_equal "Mentioners:ImAMentionable:#{@mentionable.id}:ImAMentioner", mentioners_key(@mentioner.class, @mentionable)
      end

      should "return valid key when mentioner is nil" do
        assert_equal "Mentioners:ImAMentionable:#{@mentionable.id}", mentioners_key(nil, @mentionable)
      end
    end

    context "#generate_mentionables_key" do
      should "return valid key when passed objects" do
        assert_equal "Mentionables:ImAMentioner:#{@mentioner.id}:ImAMentionable", mentionables_key(@mentioner, @mentionable)
      end

      should "return valid key when mentionable is a class" do
        assert_equal "Mentionables:ImAMentioner:#{@mentioner.id}:ImAMentionable", mentionables_key(@mentioner, @mentionable.class)
      end

      should "return valid key when mentionable is nil" do
        assert_equal "Mentionables:ImAMentioner:#{@mentioner.id}", mentionables_key(@mentioner, nil)
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

  def mentioners_key(mentioner = nil, mentionable = nil)
    @klass.send(:generate_mentioners_key, mentioner, mentionable)
  end

  def mentionables_key(mentioner = nil, mentionable = nil)
    @klass.send(:generate_mentionables_key, mentioner, mentionable)
  end
end
