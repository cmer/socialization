require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'

class RedisLikeStoreTest < Test::Unit::TestCase
  context "RedisStores::LikeStoreTest" do
    setup do
      use_redis_store
      @klass = Socialization::RedisStores::Like
      @klass.touch nil
      @klass.after_like nil
      @klass.after_unlike nil
      @liker = ImALiker.create
      @likeable = ImALikeable.create
    end

    context "Stores" do
      should "inherit Socialization::RedisStores::Like" do
        assert_equal Socialization::RedisStores::Like, Socialization.like_model
      end
    end

    context "#like!" do
      should "create a Like record" do
        @klass.like!(@liker, @likeable)
        assert_equal ["#{@liker.id}"], Socialization.redis.smembers(likers_key(@liker, @likeable))
        assert_equal ["#{@likeable.id}"], Socialization.redis.smembers(likeables_key(@liker, @likeable))
      end

      should "touch liker when instructed" do
        @klass.touch :liker
        @liker.expects(:touch).once
        @likeable.expects(:touch).never
        @klass.like!(@liker, @likeable)
      end

      should "touch likeable when instructed" do
        @klass.touch :likeable
        @liker.expects(:touch).never
        @likeable.expects(:touch).once
        @klass.like!(@liker, @likeable)
      end

      should "touch all when instructed" do
        @klass.touch :all
        @liker.expects(:touch).once
        @likeable.expects(:touch).once
        @klass.like!(@liker, @likeable)
      end

      should "call after like hook" do
        @klass.after_like :after_like
        @klass.expects(:after_like).once
        @klass.like!(@liker, @likeable)
      end

      should "call after unlike hook" do
        @klass.after_like :after_unlike
        @klass.expects(:after_unlike).once
        @klass.like!(@liker, @likeable)
      end
    end

    context "#likes?" do
      should "return true when like exists" do
        Socialization.redis.sadd likers_key(@liker, @likeable), @liker.id
        Socialization.redis.sadd likeables_key(@liker, @likeable), @likeable.id
        assert_true @klass.likes?(@liker, @likeable)
      end

      should "return false when like doesn't exist" do
        assert_false @klass.likes?(@liker, @likeable)
      end
    end

    context "#likers" do
      should "return an array of likers" do
        liker1 = ImALiker.create
        liker2 = ImALiker.create
        liker1.like!(@likeable)
        liker2.like!(@likeable)
        assert_array_similarity [liker1, liker2], @klass.likers(@likeable, liker1.class)
      end

      should "return an array of liker ids when plucking" do
        liker1 = ImALiker.create
        liker2 = ImALiker.create
        liker1.like!(@likeable)
        liker2.like!(@likeable)
        assert_array_similarity [liker1.id, liker2.id], @klass.likers(@likeable, liker1.class, :pluck => :id)
      end
    end

    context "#likeables" do
      should "return an array of likeables" do
        likeable1 = ImALikeable.create
        likeable2 = ImALikeable.create
        @liker.like!(likeable1)
        @liker.like!(likeable2)

        assert_array_similarity [likeable1, likeable2], @klass.likeables(@liker, likeable1.class)
      end

      should "return an array of likeables ids when plucking" do
        likeable1 = ImALikeable.create
        likeable2 = ImALikeable.create
        @liker.like!(likeable1)
        @liker.like!(likeable2)
        assert_array_similarity [likeable1.id, likeable2.id], @klass.likeables(@liker, likeable1.class, :pluck => :id)
      end
    end

    context "#generate_likers_key" do
      should "return valid key when passed objects" do
        assert_equal "Likers:ImALikeable:#{@likeable.id}:ImALiker", likers_key(@liker, @likeable)
      end

      should "return valid key when liker is a class" do
        assert_equal "Likers:ImALikeable:#{@likeable.id}:ImALiker", likers_key(@liker.class, @likeable)
      end

      should "return valid key when liker is nil" do
        assert_equal "Likers:ImALikeable:#{@likeable.id}", likers_key(nil, @likeable)
      end
    end

    context "#generate_likeables_key" do
      should "return valid key when passed objects" do
        assert_equal "Likeables:ImALiker:#{@liker.id}:ImALikeable", likeables_key(@liker, @likeable)
      end

      should "return valid key when likeable is a class" do
        assert_equal "Likeables:ImALiker:#{@liker.id}:ImALikeable", likeables_key(@liker, @likeable.class)
      end

      should "return valid key when likeable is nil" do
        assert_equal "Likeables:ImALiker:#{@liker.id}", likeables_key(@liker, nil)
      end
    end

  end

  # Helpers
  def assert_match_liker(like_record, liker)
    assert like_record.liker_type ==  liker.class.to_s && like_record.liker_id == liker.id
  end

  def assert_match_likeable(like_record, likeable)
    assert like_record.likeable_type ==  likeable.class.to_s && like_record.likeable_id == likeable.id
  end

  def likers_key(liker = nil, likeable = nil)
    @klass.send(:generate_likers_key, liker, likeable)
  end

  def likeables_key(liker = nil, likeable = nil)
    @klass.send(:generate_likeables_key, liker, likeable)
  end
end
