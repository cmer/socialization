require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'

class RedisFollowStoreTest < Test::Unit::TestCase
  context "RedisStores::FollowStoreTest" do
    setup do
      use_redis_store
      @klass = Socialization::RedisStores::FollowStore
      @klass.touch nil
      @klass.after_follow nil
      @klass.after_unfollow nil
      @follower = ImAFollower.create
      @followable = ImAFollowable.create
    end

    context "Stores" do
      should "inherit Socialization::RedisStores::FollowStore" do
        assert_equal Socialization::RedisStores::FollowStore, Socialization.follow_model
      end
    end

    context "#follow!" do
      should "create a Follow record" do
        @klass.follow!(@follower, @followable)
        assert_equal ["#{@follower.id}"], Socialization.redis.smembers(followers_key)
        assert_equal ["#{@followable.id}"], Socialization.redis.smembers(followables_key)
      end

      should "touch follower when instructed" do
        @klass.touch :follower
        @follower.expects(:touch).once
        @followable.expects(:touch).never
        @klass.follow!(@follower, @followable)
      end

      should "touch followable when instructed" do
        @klass.touch :followable
        @follower.expects(:touch).never
        @followable.expects(:touch).once
        @klass.follow!(@follower, @followable)
      end

      should "touch all when instructed" do
        @klass.touch :all
        @follower.expects(:touch).once
        @followable.expects(:touch).once
        @klass.follow!(@follower, @followable)
      end

      should "call after follow hook" do
        @klass.after_follow :after_follow
        @klass.expects(:after_follow).once
        @klass.follow!(@follower, @followable)
      end

      should "call after unfollow hook" do
        @klass.after_follow :after_unfollow
        @klass.expects(:after_unfollow).once
        @klass.follow!(@follower, @followable)
      end
    end

    context "#follows?" do
      should "return true when follow exists" do
        Socialization.redis.sadd followers_key, @follower.id
        Socialization.redis.sadd followables_key, @followable.id
        assert_true @klass.follows?(@follower, @followable)
      end

      should "return false when follow doesn't exist" do
        assert_false @klass.follows?(@follower, @followable)
      end
    end

    context "#followers" do
      should "return an array of followers" do
        follower1 = ImAFollower.create
        follower2 = ImAFollower.create
        follower1.follow!(@followable)
        follower2.follow!(@followable)
        assert_array_similarity [follower1, follower2], @klass.followers(@followable, follower1.class)
      end

      should "return an array of follower ids when plucking" do
        follower1 = ImAFollower.create
        follower2 = ImAFollower.create
        follower1.follow!(@followable)
        follower2.follow!(@followable)
        assert_array_similarity [follower1.id, follower2.id], @klass.followers(@followable, follower1.class, :pluck => :id)
      end
    end

    context "#followables" do
      should "return an array of followables" do
        followable1 = ImAFollowable.create
        followable2 = ImAFollowable.create
        @follower.follow!(followable1)
        @follower.follow!(followable2)

        assert_array_similarity [followable1, followable2], @klass.followables(@follower, followable1.class)
      end

      should "return an array of followables ids when plucking" do
        followable1 = ImAFollowable.create
        followable2 = ImAFollowable.create
        @follower.follow!(followable1)
        @follower.follow!(followable2)
        assert_array_similarity [followable1.id, followable2.id], @klass.followables(@follower, followable1.class, :pluck => :id)
      end
    end

    context "#generate_followers_key" do
      should "return valid key when passed objects" do
        assert_equal "Followers:ImAFollowable:#{@followable.id}:ImAFollower", followers_key(@follower, @followable)
      end

      should "return valid key when follower is a class" do
        assert_equal "Followers:ImAFollowable:#{@followable.id}:ImAFollower", followers_key(@follower.class, @followable)
      end
    end

    context "#generate_followables_key" do
      should "return valid key when passed objects" do
        assert_equal "Followables:ImAFollower:#{@follower.id}:ImAFollowable", followables_key(@follower, @followable)
      end

      should "return valid key when followable is a class" do
        assert_equal "Followables:ImAFollower:#{@follower.id}:ImAFollowable", followables_key(@follower, @followable.class)
      end
    end

  end

  # Helpers
  def assert_match_follower(follow_record, follower)
    assert follow_record.follower_type ==  follower.class.to_s && follow_record.follower_id == follower.id
  end

  def assert_match_followable(follow_record, followable)
    assert follow_record.followable_type ==  followable.class.to_s && follow_record.followable_id == followable.id
  end

  def followers_key(follower = nil, followable = nil)
    follower ||= @follower
    followable ||= @followable
    @klass.send(:generate_followers_key, follower, followable)
  end

  def followables_key(follower = nil, followable = nil)
    follower ||= @follower
    followable ||= @followable
    @klass.send(:generate_followables_key, follower, followable)
  end
end
