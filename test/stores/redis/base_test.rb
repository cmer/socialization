require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'

class RedisBaseStoreTest < Test::Unit::TestCase
  # Testing through RedisStores::Follow for easy testing
  context "RedisStores::Base through RedisStores::Follow" do
    setup do
      use_redis_store
      @klass = Socialization::RedisStores::Follow
      @klass.touch nil
      @klass.after_follow nil
      @klass.after_unfollow nil
      @follower1 = ImAFollower.create
      @follower2 = ImAFollower.create
      @followable1 = ImAFollowable.create
      @followable2 = ImAFollowable.create
    end

    context "Stores" do
      should "inherit Socialization::RedisStores::Follow" do
        assert_equal Socialization::RedisStores::Follow, Socialization.follow_model
      end
    end

    context "#follow!" do
      should "create follow records" do
        @klass.follow!(@follower1, @followable1)
        assert_array_similarity ["#{@follower1.class}:#{@follower1.id}"], Socialization.redis.smembers(forward_key(@followable1))
        assert_array_similarity ["#{@followable1.class}:#{@followable1.id}"], Socialization.redis.smembers(backward_key(@follower1))

        @klass.follow!(@follower2, @followable1)
        assert_array_similarity ["#{@follower1.class}:#{@follower1.id}", "#{@follower2.class}:#{@follower2.id}"], Socialization.redis.smembers(forward_key(@followable1))
        assert_array_similarity ["#{@followable1.class}:#{@followable1.id}"], Socialization.redis.smembers(backward_key(@follower1))
        assert_array_similarity ["#{@followable1.class}:#{@followable1.id}"], Socialization.redis.smembers(backward_key(@follower2))
      end

      should "touch follower when instructed" do
        @klass.touch :follower
        @follower1.expects(:touch).once
        @followable1.expects(:touch).never
        @klass.follow!(@follower1, @followable1)
      end

      should "touch followable when instructed" do
        @klass.touch :followable
        @follower1.expects(:touch).never
        @followable1.expects(:touch).once
        @klass.follow!(@follower1, @followable1)
      end

      should "touch all when instructed" do
        @klass.touch :all
        @follower1.expects(:touch).once
        @followable1.expects(:touch).once
        @klass.follow!(@follower1, @followable1)
      end

      should "call after follow hook" do
        @klass.after_follow :after_follow
        @klass.expects(:after_follow).once
        @klass.follow!(@follower1, @followable1)
      end

      should "call after unfollow hook" do
        @klass.after_follow :after_unfollow
        @klass.expects(:after_unfollow).once
        @klass.follow!(@follower1, @followable1)
      end
    end

    context "#unfollow!" do
      setup do
        @klass.follow!(@follower1, @followable1)
      end

      should "remove follow records" do
        @klass.unfollow!(@follower1, @followable1)
        assert_empty Socialization.redis.smembers forward_key(@followable1)
        assert_empty Socialization.redis.smembers backward_key(@follower1)
      end
    end

    context "#follows?" do
      should "return true when follow exists" do
        @klass.follow!(@follower1, @followable1)
        assert_true @klass.follows?(@follower1, @followable1)
      end

      should "return false when follow doesn't exist" do
        assert_false @klass.follows?(@follower1, @followable1)
      end
    end

    context "#followers" do
      should "return an array of followers" do
        follower1 = ImAFollower.create
        follower2 = ImAFollower.create
        follower1.follow!(@followable1)
        follower2.follow!(@followable1)
        assert_array_similarity [follower1, follower2], @klass.followers(@followable1, follower1.class)
      end

      should "return an array of follower ids when plucking" do
        follower1 = ImAFollower.create
        follower2 = ImAFollower.create
        follower1.follow!(@followable1)
        follower2.follow!(@followable1)
        assert_array_similarity ["#{follower1.id}", "#{follower2.id}"], @klass.followers(@followable1, follower1.class, :pluck => :id)
      end
    end

    context "#followables" do
      should "return an array of followables" do
        followable1 = ImAFollowable.create
        followable2 = ImAFollowable.create
        @follower1.follow!(followable1)
        @follower1.follow!(followable2)

        assert_array_similarity [followable1, followable2], @klass.followables(@follower1, followable1.class)
      end

      should "return an array of followables ids when plucking" do
        followable1 = ImAFollowable.create
        followable2 = ImAFollowable.create
        @follower1.follow!(followable1)
        @follower1.follow!(followable2)
        assert_array_similarity ["#{followable1.id}", "#{followable2.id}"], @klass.followables(@follower1, followable1.class, :pluck => :id)
      end
    end

    context "#generate_forward_key" do
      should "return valid key when passed an object" do
        assert_equal "Followers:#{@followable1.class.name}:#{@followable1.id}", forward_key(@followable1)
      end

      should "return valid key when passed a String" do
        assert_equal "Followers:Followable:1", forward_key("Followable:1")
      end
    end

    context "#generate_backward_key" do
      should "return valid key when passed an object" do
        assert_equal "Followables:#{@follower1.class.name}:#{@follower1.id}", backward_key(@follower1)
      end

      should "return valid key when passed a String" do
        assert_equal "Followables:Follower:1", backward_key("Follower:1")
      end
    end

    context "#remove_followers" do
      should "delete all followers relationships for a followable" do
        @follower1.follow!(@followable1)
        @follower2.follow!(@followable1)
        assert_equal 2, @followable1.followers(@follower1.class).count

        @klass.remove_followers(@followable1)
        assert_equal 0, @followable1.followers(@follower1.class).count
        assert_empty Socialization.redis.smembers forward_key(@followable1)
        assert_empty Socialization.redis.smembers backward_key(@follower1)
        assert_empty Socialization.redis.smembers backward_key(@follower2)
      end
    end

    context "#remove_followables" do
      should "delete all followables relationships for a follower" do
        @follower1.follow!(@followable1)
        @follower1.follow!(@followable2)
        assert_equal 2, @follower1.followables(@followable1.class).count

        @klass.remove_followables(@follower1)
        assert_equal 0, @follower1.followables(@followable1.class).count
        assert_empty Socialization.redis.smembers backward_key(@followable1)
        assert_empty Socialization.redis.smembers backward_key(@follower2)
        assert_empty Socialization.redis.smembers forward_key(@follower1)
      end
    end

    context "#key_type_to_type_names" do
      should "return the proper arrays" do
        assert_equal ['follower', 'followable'], @klass.send(:key_type_to_type_names, Socialization::RedisStores::Follow)
        assert_equal ['mentioner', 'mentionable'], @klass.send(:key_type_to_type_names, Socialization::RedisStores::Mention)
        assert_equal ['liker', 'likeable'], @klass.send(:key_type_to_type_names, Socialization::RedisStores::Like)
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

  def forward_key(followable)
    Socialization::RedisStores::Follow.send(:generate_forward_key, followable)
  end

  def backward_key(follower)
    Socialization::RedisStores::Follow.send(:generate_backward_key, follower)
  end
end
