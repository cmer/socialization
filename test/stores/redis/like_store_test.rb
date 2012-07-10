require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'

class RedisLikeStoreTest < Test::Unit::TestCase
  context "RedisStores::Like" do
    setup do
      use_redis_store
      @klass = Socialization::RedisStores::Like
      @base = Socialization::RedisStores::Base
    end

    context "method aliases" do
      should "be set properly and made public" do
        assert_method_public @klass, :like!
        assert_method_public @klass, :unlike!
        assert_method_public @klass, :likes?
        assert_method_public @klass, :likers_relation
        assert_method_public @klass, :likers
        assert_method_public @klass, :likeables_relation
        assert_method_public @klass, :likeables
        assert_method_public @klass, :remove_likers
        assert_method_public @klass, :remove_likeables
      end
    end
  end
end