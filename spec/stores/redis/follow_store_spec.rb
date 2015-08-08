require 'spec_helper'

describe Socialization::RedisStores::Follow do
  before do
    use_redis_store
    @klass = Socialization::RedisStores::Follow
    @base = Socialization::RedisStores::Base
  end

  describe "method aliases" do
    it "should be set properly and made public" do
      # TODO: Can't figure out how to test method aliases properly. The following doesn't work:
      # assert @klass.method(:follow!) == @base.method(:relation!)
      expect(:follow!).to be_a_public_method_of(@klass)
      expect(:unfollow!).to be_a_public_method_of(@klass)
      expect(:follows?).to be_a_public_method_of(@klass)
      expect(:followers_relation).to be_a_public_method_of(@klass)
      expect(:followers).to be_a_public_method_of(@klass)
      expect(:followables_relation).to be_a_public_method_of(@klass)
      expect(:followables).to be_a_public_method_of(@klass)
      expect(:remove_followers).to be_a_public_method_of(@klass)
      expect(:remove_followables).to be_a_public_method_of(@klass)
    end
  end

end
