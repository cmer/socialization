require 'spec_helper'

describe Socialization::RedisStores::Base do
  # Testing through RedisStores::Follow for easy testing
  before(:each) do
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

  describe "RedisStores::Base through RedisStores::Follow" do
    describe "Stores" do
      it "inherits Socialization::RedisStores::Follow" do
        expect(Socialization.follow_model).to eq(Socialization::RedisStores::Follow)
      end
    end

    describe "#follow!" do
      it "creates follow records" do
        @klass.follow!(@follower1, @followable1)
        expect(Socialization.redis.smembers(forward_key(@followable1))).to match_array ["#{@follower1.class}:#{@follower1.id}"]
        expect(Socialization.redis.smembers(backward_key(@follower1))).to match_array ["#{@followable1.class}:#{@followable1.id}"]

        @klass.follow!(@follower2, @followable1)
        expect(Socialization.redis.smembers(forward_key(@followable1))).to match_array ["#{@follower1.class}:#{@follower1.id}", "#{@follower2.class}:#{@follower2.id}"]
        expect(Socialization.redis.smembers(backward_key(@follower1))).to match_array ["#{@followable1.class}:#{@followable1.id}"]
        expect(Socialization.redis.smembers(backward_key(@follower2))).to match_array ["#{@followable1.class}:#{@followable1.id}"]
      end

      it "touches follower when instructed" do
        @klass.touch :follower
        expect(@follower1).to receive(:touch).once
        expect(@followable1).to receive(:touch).never
        @klass.follow!(@follower1, @followable1)
      end

      it "touches followable when instructed" do
        @klass.touch :followable
        expect(@follower1).to receive(:touch).never
        expect(@followable1).to receive(:touch).once
        @klass.follow!(@follower1, @followable1)
      end

      it "touches all when instructed" do
        @klass.touch :all
        expect(@follower1).to receive(:touch).once
        expect(@followable1).to receive(:touch).once
        @klass.follow!(@follower1, @followable1)
      end

      it "calls after follow hook" do
        @klass.after_follow :after_follow
        expect(@klass).to receive(:after_follow).once
        @klass.follow!(@follower1, @followable1)
      end

      it "calls after unfollow hook" do
        @klass.after_follow :after_unfollow
        expect(@klass).to receive(:after_unfollow).once
        @klass.follow!(@follower1, @followable1)
      end
    end

    describe "#unfollow!" do
      before(:each) do
        @klass.follow!(@follower1, @followable1)
      end

      it "removes follow records" do
        @klass.unfollow!(@follower1, @followable1)
        expect(Socialization.redis.smembers(forward_key(@followable1))).to be_empty
        expect(Socialization.redis.smembers(backward_key(@follower1))).to be_empty
      end
    end

    describe "#follows?" do
      it "returns true when follow exists" do
        @klass.follow!(@follower1, @followable1)
        expect(@klass.follows?(@follower1, @followable1)).to be true
      end

      it "returns false when follow doesn't exist" do
        expect(@klass.follows?(@follower1, @followable1)).to be false
      end
    end

    describe "#followers" do
      it "returns an array of followers" do
        follower1 = ImAFollower.create
        follower2 = ImAFollower.create
        follower1.follow!(@followable1)
        follower2.follow!(@followable1)
        expect(@klass.followers(@followable1, follower1.class)).to match_array [follower1, follower2]
      end

      it "returns an array of follower ids when plucking" do
        follower1 = ImAFollower.create
        follower2 = ImAFollower.create
        follower1.follow!(@followable1)
        follower2.follow!(@followable1)
        expect(@klass.followers(@followable1, follower1.class, :pluck => :id)).to match_array ["#{follower1.id}", "#{follower2.id}"]
      end
    end

    describe "#followables" do
      it "returns an array of followables" do
        followable1 = ImAFollowable.create
        followable2 = ImAFollowable.create
        @follower1.follow!(followable1)
        @follower1.follow!(followable2)

        expect(@klass.followables(@follower1, followable1.class)).to match_array [followable1, followable2]
      end

      it "returns an array of followables ids when plucking" do
        followable1 = ImAFollowable.create
        followable2 = ImAFollowable.create
        @follower1.follow!(followable1)
        @follower1.follow!(followable2)
        expect(@klass.followables(@follower1, followable1.class, :pluck => :id)).to match_array ["#{followable1.id}", "#{followable2.id}"]
      end
    end

    describe "#generate_forward_key" do
      it "returns valid key when passed an object" do
        expect(forward_key(@followable1)).to eq("Followers:#{@followable1.class.name}:#{@followable1.id}")
      end

      it "returns valid key when passed a String" do
        expect(forward_key("Followable:1")).to eq("Followers:Followable:1")
      end
    end

    describe "#generate_backward_key" do
      it "returns valid key when passed an object" do
        expect(backward_key(@follower1)).to eq("Followables:#{@follower1.class.name}:#{@follower1.id}")
      end

      it "returns valid key when passed a String" do
        expect(backward_key("Follower:1")).to eq("Followables:Follower:1")
      end
    end

    describe "#remove_followers" do
      it "deletes all followers relationships for a followable" do
        @follower1.follow!(@followable1)
        @follower2.follow!(@followable1)
        expect(@followable1.followers(@follower1.class).count).to eq(2)

        @klass.remove_followers(@followable1)
        expect(@followable1.followers(@follower1.class).count).to eq(0)
        expect(Socialization.redis.smembers(forward_key(@followable1))).to be_empty
        expect(Socialization.redis.smembers(backward_key(@follower1))).to be_empty
        expect(Socialization.redis.smembers(backward_key(@follower2))).to be_empty
      end
    end

    describe "#remove_followables" do
      it "deletes all followables relationships for a follower" do
        @follower1.follow!(@followable1)
        @follower1.follow!(@followable2)
        expect(@follower1.followables(@followable1.class).count).to eq(2)

        @klass.remove_followables(@follower1)
        expect(@follower1.followables(@followable1.class).count).to eq(0)
        expect(Socialization.redis.smembers backward_key(@followable1)).to be_empty
        expect(Socialization.redis.smembers backward_key(@follower2)).to be_empty
        expect(Socialization.redis.smembers forward_key(@follower1)).to be_empty
      end
    end

    describe "#key_type_to_type_names" do
      it "returns the proper arrays" do
        expect(@klass.send(:key_type_to_type_names, Socialization::RedisStores::Follow)).to eq(['follower', 'followable'])
        expect(@klass.send(:key_type_to_type_names, Socialization::RedisStores::Mention)).to eq(['mentioner', 'mentionable'])
        expect(@klass.send(:key_type_to_type_names, Socialization::RedisStores::Like)).to eq(['liker', 'likeable'])
      end
    end
  end

  # Helpers
  def forward_key(followable)
    Socialization::RedisStores::Follow.send(:generate_forward_key, followable)
  end

  def backward_key(follower)
    Socialization::RedisStores::Follow.send(:generate_backward_key, follower)
  end
end
