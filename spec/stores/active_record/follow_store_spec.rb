require 'spec_helper'

describe Socialization::ActiveRecordStores::Follow do
  before do
    @klass = Socialization::ActiveRecordStores::Follow
    @klass.touch nil
    @klass.after_follow nil
    @klass.after_unfollow nil
    @follower = ImAFollower.create
    @followable = ImAFollowable.create
  end

  describe "data store" do
    it "inherits Socialization::ActiveRecordStores::Follow" do
      expect(Socialization.follow_model).to eq(Socialization::ActiveRecordStores::Follow)
    end
  end

  describe "#follow!" do
    it "creates a Follow record" do
      @klass.follow!(@follower, @followable)
      expect(@follower).to match_follower(@klass.last)
      expect(@followable).to match_followable(@klass.last)
    end

    it "increments counter caches" do
      follower   = ImAFollowerWithCounterCache.create
      followable = ImAFollowableWithCounterCache.create
      @klass.follow!(follower, followable)
      expect(follower.reload.followees_count).to eq(1)
      expect(followable.reload.followers_count).to eq(1)
    end

    it "touches follower when instructed" do
      @klass.touch :follower
      expect(@follower).to receive(:touch).once
      expect(@followable).to receive(:touch).never
      @klass.follow!(@follower, @followable)
    end

    it "touches followable when instructed" do
      @klass.touch :followable
      expect(@follower).to receive(:touch).never
      expect(@followable).to receive(:touch).once
      @klass.follow!(@follower, @followable)
    end

    it "touches all when instructed" do
      @klass.touch :all
      expect(@follower).to receive(:touch).once
      expect(@followable).to receive(:touch).once
      @klass.follow!(@follower, @followable)
    end

    it "calls after follow hook" do
      @klass.after_follow :after_follow
      expect(@klass).to receive(:after_follow).once
      @klass.follow!(@follower, @followable)
    end

    it "calls after unfollow hook" do
      @klass.after_follow :after_unfollow
      expect(@klass).to receive(:after_unfollow).once
      @klass.follow!(@follower, @followable)
    end
  end

  describe "#unfollow!" do
    it "decrements counter caches" do
      follower   = ImAFollowerWithCounterCache.create
      followable = ImAFollowableWithCounterCache.create
      @klass.follow!(follower, followable)
      @klass.unfollow!(follower, followable)
      expect(follower.reload.followees_count).to eq(0)
      expect(followable.reload.followers_count).to eq(0)
    end
  end

  describe "#follows?" do
    it "returns true when follow exists" do
      @klass.create! do |f|
        f.follower = @follower
        f.followable = @followable
      end
      expect(@klass.follows?(@follower, @followable)).to be true
    end

    it "returns false when follow doesn't exist" do
      expect(@klass.follows?(@follower, @followable)).to be false
    end
  end

  describe "#followers" do
    it "returns an array of followers" do
      follower1 = ImAFollower.create
      follower2 = ImAFollower.create
      follower1.follow!(@followable)
      follower2.follow!(@followable)
      expect(@klass.followers(@followable, follower1.class)).to eq([follower1, follower2])
    end

    it "returns an array of follower ids when plucking" do
      follower1 = ImAFollower.create
      follower2 = ImAFollower.create
      follower1.follow!(@followable)
      follower2.follow!(@followable)
      expect(@klass.followers(@followable, follower1.class, :pluck => :id)).to eq([follower1.id, follower2.id])
    end
  end

  describe "#followables" do
    it "returns an array of followers" do
      followable1 = ImAFollowable.create
      followable2 = ImAFollowable.create
      @follower.follow!(followable1)
      @follower.follow!(followable2)
      expect(@klass.followables(@follower, followable1.class)).to eq([followable1, followable2])
    end

    it "returns an array of follower ids when plucking" do
      followable1 = ImAFollowable.create
      followable2 = ImAFollowable.create
      @follower.follow!(followable1)
      @follower.follow!(followable2)
      expect(@klass.followables(@follower, followable1.class, :pluck => :id)).to eq([followable1.id, followable2.id])
    end
  end

  describe "#remove_followers" do
    it "deletes all followers relationships for a followable" do
      @follower.follow!(@followable)
      expect(@followable.followers(@follower.class).count).to eq(1)
      @klass.remove_followers(@followable)
      expect(@followable.followers(@follower.class).count).to eq(0)
    end
  end

  describe "#remove_followables" do
    it "deletes all followables relationships for a follower" do
      @follower.follow!(@followable)
      expect(@follower.followables(@followable.class).count).to eq(1)
      @klass.remove_followables(@follower)
      expect(@follower.followables(@followable.class).count).to eq(0)
    end
  end
end

