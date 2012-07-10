require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'

class RedisFollowStoreTest < Test::Unit::TestCase
  context "RedisStores::Follow" do
    setup do
      use_redis_store
      @klass = Socialization::RedisStores::Follow
      @base = Socialization::RedisStores::Base
    end

    context "method aliases" do
      should "be set properly and made public" do
        # TODO: Can't figure out how to test method aliases properly. The following doesn't work:
        # assert @klass.method(:follow!) == @base.method(:relation!)
        assert_method_public @klass, :follow!
        assert_method_public @klass, :unfollow!
        assert_method_public @klass, :follows?
        assert_method_public @klass, :followers_relation
        assert_method_public @klass, :followers
        assert_method_public @klass, :followables_relation
        assert_method_public @klass, :followables
        assert_method_public @klass, :remove_followers
        assert_method_public @klass, :remove_followables
      end
    end
  end
end