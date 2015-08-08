require 'spec_helper'

describe Socialization::ActiveRecordStores::Like do
  before do
    @klass = Socialization::ActiveRecordStores::Like
    @klass.touch nil
    @klass.after_like nil
    @klass.after_unlike nil
    @liker = ImALiker.create
    @likeable = ImALikeable.create
  end

  describe "data store" do
    it "inherits Socialization::ActiveRecordStores::Like" do
      expect(Socialization.like_model).to eq Socialization::ActiveRecordStores::Like
    end
  end

  describe "#like!" do
    it "creates a Like record" do
      @klass.like!(@liker, @likeable)
      expect(@liker).to match_liker @klass.last
      expect(@likeable).to match_likeable @klass.last
    end

    it "increments counter caches" do
      liker    = ImALikerWithCounterCache.create
      likeable = ImALikeableWithCounterCache.create
      @klass.like!(liker, likeable)
      expect(liker.reload.likees_count).to eq(1)
      expect(likeable.reload.likers_count).to eq(1)
    end

    it "touches liker when instructed" do
      @klass.touch :liker
      expect(@liker).to receive(:touch).once
      expect(@likeable).to receive(:touch).never
      @klass.like!(@liker, @likeable)
    end

    it "touches likeable when instructed" do
      @klass.touch :likeable
      expect(@liker).to receive(:touch).never
      expect(@likeable).to receive(:touch).once
      @klass.like!(@liker, @likeable)
    end

    it "touches all when instructed" do
      @klass.touch :all
      expect(@liker).to receive(:touch).once
      expect(@likeable).to receive(:touch).once
      @klass.like!(@liker, @likeable)
    end

    it "calls after like hook" do
      @klass.after_like :after_like
      expect(@klass).to receive(:after_like).once
      @klass.like!(@liker, @likeable)
    end

    it "calls after unlike hook" do
      @klass.after_like :after_unlike
      expect(@klass).to receive(:after_unlike).once
      @klass.like!(@liker, @likeable)
    end
  end

  describe "#unlike!" do
    it "decrements counter caches" do
      liker    = ImALikerWithCounterCache.create
      likeable = ImALikeableWithCounterCache.create
      @klass.like!(liker, likeable)
      @klass.unlike!(liker, likeable)
      expect(liker.reload.likees_count).to eq 0
      expect(likeable.reload.likers_count).to eq 0
    end
  end

  describe "#likes?" do
    it "returns true when like exists" do
      @klass.create! do |f|
        f.liker = @liker
        f.likeable = @likeable
      end
      expect(@klass.likes?(@liker, @likeable)).to be true
    end

    it "returns false when like doesn't exist" do
      expect(@klass.likes?(@liker, @likeable)).to be false
    end
  end

  describe "#likers" do
    it "returns an array of likers" do
      liker1 = ImALiker.create
      liker2 = ImALiker.create
      liker1.like!(@likeable)
      liker2.like!(@likeable)
      expect(@klass.likers(@likeable, liker1.class)).to eq [liker1, liker2]
    end

    it "returns an array of liker ids when plucking" do
      liker1 = ImALiker.create
      liker2 = ImALiker.create
      liker1.like!(@likeable)
      liker2.like!(@likeable)
      expect(@klass.likers(@likeable, liker1.class, :pluck => :id)).to eq [liker1.id, liker2.id]
    end
  end

  describe "#likeables" do
    it "returns an array of likers" do
      likeable1 = ImALikeable.create
      likeable2 = ImALikeable.create
      @liker.like!(likeable1)
      @liker.like!(likeable2)
      expect(@klass.likeables(@liker, likeable1.class)).to eq [likeable1, likeable2]
    end

    it "returns an array of liker ids when plucking" do
      likeable1 = ImALikeable.create
      likeable2 = ImALikeable.create
      @liker.like!(likeable1)
      @liker.like!(likeable2)
      expect(@klass.likeables(@liker, likeable1.class, :pluck => :id)).to eq [likeable1.id, likeable2.id]
    end
  end

  describe "#remove_likers" do
    it "deletes all likers relationships for a likeable" do
      @liker.like!(@likeable)
      expect(@likeable.likers(@liker.class).count).to eq 1
      @klass.remove_likers(@likeable)
      expect(@likeable.likers(@liker.class).count).to eq 0
    end
  end

  describe "#remove_likeables" do
    it "deletes all likeables relationships for a liker" do
      @liker.like!(@likeable)
      expect(@liker.likeables(@likeable.class).count).to eq 1
      @klass.remove_likeables(@liker)
      expect(@liker.likeables(@likeable.class).count).to eq 0
    end
  end
end
