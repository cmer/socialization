require 'spec_helper'

describe Socialization::RedisStores::Like do
  before do
    use_redis_store
    @klass = Socialization::RedisStores::Like
    @base = Socialization::RedisStores::Base
  end

  describe "method aliases" do
    it "should be set properly and made public" do
      expect(:like!).to be_a_public_method_of(@klass)
      expect(:unlike!).to be_a_public_method_of(@klass)
      expect(:likes?).to be_a_public_method_of(@klass)
      expect(:likers_relation).to be_a_public_method_of(@klass)
      expect(:likers).to be_a_public_method_of(@klass)
      expect(:likeables_relation).to be_a_public_method_of(@klass)
      expect(:likeables).to be_a_public_method_of(@klass)
      expect(:remove_likers).to be_a_public_method_of(@klass)
      expect(:remove_likeables).to be_a_public_method_of(@klass)
    end
  end
end
