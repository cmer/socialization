require 'spec_helper'

describe Socialization::Liker do
  before(:all) do
    use_ar_store
    @liker = ImALiker.new
    @likeable = ImALikeable.create
  end

  describe "#is_liker?" do
    it "returns true" do
      expect(@liker.is_liker?).to be true
    end
  end

  describe "#liker?" do
    it "returns true" do
      expect(@liker.liker?).to be true
    end
  end

  describe "#like!" do
    it "does not accept non-likeables" do
      expect { @liker.like!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Like.like!" do
      expect($Like).to receive(:like!).with(@liker, @likeable).once
      @liker.like!(@likeable)
    end
  end

  describe "#unlike!" do
    it "does not accept non-likeables" do
      expect { @liker.unlike!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Like.like!" do
      expect($Like).to receive(:unlike!).with(@liker, @likeable).once
      @liker.unlike!(@likeable)
    end
  end

  describe "#toggle_like!" do
    it "does not accept non-likeables" do
      expect { @liker.unlike!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "unlikes when likeing" do
      expect(@liker).to receive(:likes?).with(@likeable).once.and_return(true)
      expect(@liker).to receive(:unlike!).with(@likeable).once
      @liker.toggle_like!(@likeable)
    end

    it "likes when not likeing" do
      expect(@liker).to receive(:likes?).with(@likeable).once.and_return(false)
      expect(@liker).to receive(:like!).with(@likeable).once
      @liker.toggle_like!(@likeable)
    end
  end

  describe "#likes?" do
    it "does not accept non-likeables" do
      expect { @liker.unlike!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Like.likes?" do
      expect($Like).to receive(:likes?).with(@liker, @likeable).once
      @liker.likes?(@likeable)
    end
  end

  describe "#likeables" do
    it "calls $Like.likeables" do
      expect($Like).to receive(:likeables).with(@liker, @likeable.class, { :foo => :bar })
      @liker.likeables(@likeable.class, { :foo => :bar })
    end
  end

  describe "#likees" do
    it "calls $Like.likeables" do
      expect($Like).to receive(:likeables).with(@liker, @likeable.class, { :foo => :bar })
      @liker.likees(@likeable.class, { :foo => :bar })
    end
  end

  describe "#likeables_relation" do
    it "calls $Follow.likeables_relation" do
      expect($Like).to receive(:likeables_relation).with(@liker, @likeable.class, { :foo => :bar })
      @liker.likeables_relation(@likeable.class, { :foo => :bar })
    end
  end

  describe "#likees_relation" do
    it "calls $Follow.likeables_relation" do
      expect($Like).to receive(:likeables_relation).with(@liker, @likeable.class, { :foo => :bar })
      @liker.likees_relation(@likeable.class, { :foo => :bar })
    end
  end

  it "removes like relationships" do
    expect(Socialization.like_model).to receive(:remove_likeables).with(@liker)
    @liker.destroy
  end
end
