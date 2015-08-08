require 'spec_helper'

describe Socialization::RedisStores::Follow do
  before do
    use_redis_store
    @klass = Socialization::RedisStores::Mention
    @base = Socialization::RedisStores::Base
  end

  describe "method aliases" do
    it "should be set properly and made public" do
      expect(:mention!).to be_a_public_method_of(@klass)
      expect(:unmention!).to be_a_public_method_of(@klass)
      expect(:mentions?).to be_a_public_method_of(@klass)
      expect(:mentioners_relation).to be_a_public_method_of(@klass)
      expect(:mentioners).to be_a_public_method_of(@klass)
      expect(:mentionables_relation).to be_a_public_method_of(@klass)
      expect(:mentionables).to be_a_public_method_of(@klass)
      expect(:remove_mentioners).to be_a_public_method_of(@klass)
      expect(:remove_mentionables).to be_a_public_method_of(@klass)
    end
  end
end
