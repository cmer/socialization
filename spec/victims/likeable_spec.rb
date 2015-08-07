require 'spec_helper'

describe Socialization::Likeable do
  before(:all) do
    use_ar_store
    @liker = ImALiker.new
    @likeable = ImALikeable.create
  end

  describe "#is_likeable?" do
    it "returns true" do
      expect(@likeable.is_likeable?).to be true
    end
  end

  describe "#likeable?" do
    it "returns true" do
      expect(@likeable.likeable?).to be true
    end
  end

  describe "#liked_by?" do
    it "does not accept non-likers" do
      expect { @likeable.liked_by?(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Like.likes?" do
      expect($Like).to receive(:likes?).with(@liker, @likeable).once
      @likeable.liked_by?(@liker)
    end
  end

  describe "#likers" do
    it "calls $Like.likers" do
      expect($Like).to receive(:likers).with(@likeable, @liker.class, { :foo => :bar })
      @likeable.likers(@liker.class, { :foo => :bar })
    end
  end

  describe "#likers_relation" do
    it "calls $Like.likers_relation" do
      expect($Like).to receive(:likers_relation).with(@likeable, @liker.class, { :foo => :bar })
      @likeable.likers_relation(@liker.class, { :foo => :bar })
    end
  end

  describe "deleting a likeable" do
    before(:all) do
      @liker = ImALiker.create
      @liker.like!(@likeable)
    end

    it "removes like relationships" do
      expect(Socialization.like_model).to receive(:remove_likers).with(@likeable)
      @likeable.destroy
    end
  end
end
