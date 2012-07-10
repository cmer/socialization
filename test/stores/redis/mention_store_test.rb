require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'

class RedisMentionStoreTest < Test::Unit::TestCase
  context "RedisStores::Mention" do
    setup do
      use_redis_store
      @klass = Socialization::RedisStores::Mention
      @base = Socialization::RedisStores::Base
    end

    context "method aliases" do
      should "be set properly and made public" do
        assert_method_public @klass, :mention!
        assert_method_public @klass, :unmention!
        assert_method_public @klass, :mentions?
        assert_method_public @klass, :mentioners_relation
        assert_method_public @klass, :mentioners
        assert_method_public @klass, :mentionables_relation
        assert_method_public @klass, :mentionables
        assert_method_public @klass, :remove_mentioners
        assert_method_public @klass, :remove_mentionables
      end
    end
  end
end