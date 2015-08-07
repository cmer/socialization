require 'spec_helper'

describe Socialization::Followable do
  before(:all) do
    use_ar_store
    @follower = ImAFollower.new
    @followable = ImAFollowable.create
  end

  describe "#is_followable?" do
    it "returns true" do
      expect(@followable.is_followable?).to be true
    end
  end

  describe "#followable?" do
    it "returns true" do
      expect(@followable.followable?).to be true
    end
  end

  describe "#followed_by?" do
    it "does not accept non-followers" do
      expect { @followable.followed_by?(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Follow.follows?" do
      expect($Follow).to receive(:follows?).with(@follower, @followable).once
      @followable.followed_by?(@follower)
    end
  end

  describe "#followers" do
    it "calls $Follow.followers" do
      expect($Follow).to receive(:followers).with(@followable, @follower.class, { :foo => :bar })
      @followable.followers(@follower.class, { :foo => :bar })
    end
  end

  describe "#followers_relation" do
    it "calls $Follow.followers_relation" do
      expect($Follow).to receive(:followers_relation).with(@followable, @follower.class, { :foo => :bar })
      @followable.followers_relation(@follower.class, { :foo => :bar })
    end
  end

  describe "deleting a followable" do
    before(:all) do
      @follower = ImAFollower.create
      @follower.follow!(@followable)
    end

    it "removes follow relationships" do
      expect(Socialization.follow_model).to receive(:remove_followers).with(@followable)
      @followable.destroy
    end
  end
end

