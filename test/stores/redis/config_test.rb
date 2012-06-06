require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'

class RedisStoreConfigTest < Test::Unit::TestCase
  context "redis" do
    setup do
      Socialization.instance_eval { @redis = nil }
    end

    should "return a new Redis object when none were specified" do
      assert_instance_of Redis, Socialization.redis
    end

    should "always return the same Redis object when none were specified" do
      redis = Socialization.redis
      assert_same redis, Socialization.redis
    end

    should "be able to set and get a redis instance" do
      redis = Redis.new
      Socialization.redis = redis
      assert_same redis, Socialization.redis
    end

    should "always return the same Redis object when it was specified" do
      redis = Redis.new
      Socialization.redis = redis
      assert_same redis, Socialization.redis
    end
  end
end
