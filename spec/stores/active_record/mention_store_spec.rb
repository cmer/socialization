require 'spec_helper'

describe Socialization::ActiveRecordStores::Mention do
  before do
    @klass = Socialization::ActiveRecordStores::Mention
    @klass.touch nil
    @klass.after_mention nil
    @klass.after_unmention nil
    @mentioner = ImAMentioner.create
    @mentionable = ImAMentionable.create
  end

  describe "data store" do
    it "inherits Socialization::ActiveRecordStores::Mention" do
      expect(Socialization.mention_model).to eq Socialization::ActiveRecordStores::Mention
    end
  end

  describe "#mention!" do
    it "creates a Mention record" do
      @klass.mention!(@mentioner, @mentionable)
      expect(@mentioner).to match_mentioner(@klass.last)
      expect(@mentionable).to match_mentionable(@klass.last)
    end

    it "increments counter caches" do
      mentioner   = ImAMentionerWithCounterCache.create
      mentionable = ImAMentionableWithCounterCache.create
      @klass.mention!(mentioner, mentionable)
      expect(mentioner.reload.mentionees_count).to eq 1
      expect(mentionable.reload.mentioners_count).to eq 1
    end

    it "touchs mentioner when instructed" do
      @klass.touch :mentioner
      expect(@mentioner).to receive(:touch).once
      expect(@mentionable).to receive(:touch).never
      @klass.mention!(@mentioner, @mentionable)
    end

    it "touchs mentionable when instructed" do
      @klass.touch :mentionable
      expect(@mentioner).to receive(:touch).never
      expect(@mentionable).to receive(:touch).once
      @klass.mention!(@mentioner, @mentionable)
    end

    it "touchs all when instructed" do
      @klass.touch :all
      expect(@mentioner).to receive(:touch).once
      expect(@mentionable).to receive(:touch).once
      @klass.mention!(@mentioner, @mentionable)
    end

    it "calls after mention hook" do
      @klass.after_mention :after_mention
      expect(@klass).to receive(:after_mention).once
      @klass.mention!(@mentioner, @mentionable)
    end

    it "calls after unmention hook" do
      @klass.after_mention :after_unmention
      expect(@klass).to receive(:after_unmention).once
      @klass.mention!(@mentioner, @mentionable)
    end
  end

  describe "#unmention!" do
    it "decrements counter caches" do
      mentioner   = ImAMentionerWithCounterCache.create
      mentionable = ImAMentionableWithCounterCache.create
      @klass.mention!(mentioner, mentionable)
      @klass.unmention!(mentioner, mentionable)
      expect(mentioner.reload.mentionees_count).to eq 0
      expect(mentionable.reload.mentioners_count).to eq 0
    end
  end


  describe "#mentions?" do
    it "returns true when mention exists" do
      @klass.create! do |f|
        f.mentioner = @mentioner
        f.mentionable = @mentionable
      end
      expect(@klass.mentions?(@mentioner, @mentionable)).to be true
    end

    it "returns false when mention doesn't exist" do
      expect(@klass.mentions?(@mentioner, @mentionable)).to be false
    end
  end

  describe "#mentioners" do
    it "returns an array of mentioners" do
      mentioner1 = ImAMentioner.create
      mentioner2 = ImAMentioner.create
      mentioner1.mention!(@mentionable)
      mentioner2.mention!(@mentionable)
      expect(@klass.mentioners(@mentionable, mentioner1.class)).to eq [mentioner1, mentioner2]
    end

    it "returns an array of mentioner ids when plucking" do
      mentioner1 = ImAMentioner.create
      mentioner2 = ImAMentioner.create
      mentioner1.mention!(@mentionable)
      mentioner2.mention!(@mentionable)
      expect(@klass.mentioners(@mentionable, mentioner1.class, :pluck => :id)).to eq [mentioner1.id, mentioner2.id]
    end
  end

  describe "#mentionables" do
    it "returns an array of mentioners" do
      mentionable1 = ImAMentionable.create
      mentionable2 = ImAMentionable.create
      @mentioner.mention!(mentionable1)
      @mentioner.mention!(mentionable2)
      expect(@klass.mentionables(@mentioner, mentionable1.class)).to eq [mentionable1, mentionable2]
    end

    it "returns an array of mentioner ids when plucking" do
      mentionable1 = ImAMentionable.create
      mentionable2 = ImAMentionable.create
      @mentioner.mention!(mentionable1)
      @mentioner.mention!(mentionable2)
      expect(@klass.mentionables(@mentioner, mentionable1.class, :pluck => :id)).to eq [mentionable1.id, mentionable2.id]
    end
  end

  describe "#remove_mentioners" do
    it "deletes all mentioners relationships for a mentionable" do
      @mentioner.mention!(@mentionable)
      expect(@mentionable.mentioners(@mentioner.class).count).to eq 1
      @klass.remove_mentioners(@mentionable)
      expect(@mentionable.mentioners(@mentioner.class).count).to eq 0
    end
  end

  describe "#remove_mentionables" do
    it "deletes all mentionables relationships for a mentioner" do
      @mentioner.mention!(@mentionable)
      expect(@mentioner.mentionables(@mentionable.class).count).to eq 1
      @klass.remove_mentionables(@mentioner)
      expect(@mentioner.mentionables(@mentionable.class).count).to eq 0
    end
  end
end

