require 'spec_helper'

describe Socialization::Follower do
  before(:all) do
    use_ar_store
    @follower = ImAFollower.new
    @followable = ImAFollowable.create
  end

  describe "#is_follower?" do
    it "returns true" do
      expect(@follower.is_follower?).to be true
    end
  end

  describe "#follower?" do
    it "returns true" do
      expect(@follower.follower?).to be true
    end
  end

  describe "#follow!" do
    it "does not accept non-followables" do
      expect { @follower.follow!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Follow.follow!" do
      expect($Follow).to receive(:follow!).with(@follower, @followable).once
      @follower.follow!(@followable)
    end
  end

  describe "#unfollow!" do
    it "does not accept non-followables" do
      expect { @follower.unfollow!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Follow.follow!" do
      expect($Follow).to receive(:unfollow!).with(@follower, @followable).once
      @follower.unfollow!(@followable)
    end
  end

  describe "#toggle_follow!" do
    it "does not accept non-followables" do
      expect { @follower.unfollow!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "unfollows when following" do
      expect(@follower).to receive(:follows?).with(@followable).once.and_return(true)
      expect(@follower).to receive(:unfollow!).with(@followable).once
      @follower.toggle_follow!(@followable)
    end

    it "follows when not following" do
      expect(@follower).to receive(:follows?).with(@followable).once.and_return(false)
      expect(@follower).to receive(:follow!).with(@followable).once
      @follower.toggle_follow!(@followable)
    end
  end

  describe "#follows?" do
    it "does not accept non-followables" do
      expect { @follower.unfollow!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Follow.follows?" do
      expect($Follow).to receive(:follows?).with(@follower, @followable).once
      @follower.follows?(@followable)
    end
  end

  describe "#followables" do
    it "calls $Follow.followables" do
      expect($Follow).to receive(:followables).with(@follower, @followable.class, { :foo => :bar })
      @follower.followables(@followable.class, { :foo => :bar })
    end
  end

  describe "#followees" do
    it "calls $Follow.followables" do
      expect($Follow).to receive(:followables).with(@follower, @followable.class, { :foo => :bar })
      @follower.followees(@followable.class, { :foo => :bar })
    end
  end

  describe "#followables_relation" do
    it "calls $Follow.followables_relation" do
      expect($Follow).to receive(:followables_relation).with(@follower, @followable.class, { :foo => :bar })
      @follower.followables_relation(@followable.class, { :foo => :bar })
    end
  end

  describe "#followees_relation" do
    it "calls $Follow.followables_relation" do
      expect($Follow).to receive(:followables_relation).with(@follower, @followable.class, { :foo => :bar })
      @follower.followees_relation(@followable.class, { :foo => :bar })
    end
  end

  describe "deleting a follower" do
    before(:all) do
      @follower = ImAFollower.create
      @follower.follow!(@followable)
    end

    it "removes follow relationships" do
      expect(Socialization.follow_model).to receive(:remove_followables).with(@follower)
      @follower.destroy
    end
  end

end
