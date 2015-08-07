require 'spec_helper'

describe Socialization::Mentionable do
  before(:all) do
    use_ar_store
    @mentioner = ImAMentioner.new
    @mentionable = ImAMentionable.create
  end

  describe "#is_mentionable?" do
    it "returns true" do
      expect(@mentionable.is_mentionable?).to be true
    end
  end

  describe "#mentionable?" do
    it "returns true" do
      expect(@mentionable.mentionable?).to be true
    end
  end

  describe "#mentioned_by?" do
    it "does not accept non-mentioners" do
      expect { @mentionable.mentioned_by?(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Mention.mentions?" do
      expect($Mention).to receive(:mentions?).with(@mentioner, @mentionable).once
      @mentionable.mentioned_by?(@mentioner)
    end
  end

  describe "#mentioners" do
    it "calls $Mention.mentioners" do
      expect($Mention).to receive(:mentioners).with(@mentionable, @mentioner.class, { :foo => :bar })
      @mentionable.mentioners(@mentioner.class, { :foo => :bar })
    end
  end

  describe "#mentioners_relation" do
    it "calls $Mention.mentioners" do
      expect($Mention).to receive(:mentioners_relation).with(@mentionable, @mentioner.class, { :foo => :bar })
      @mentionable.mentioners_relation(@mentioner.class, { :foo => :bar })
    end
  end

  describe "deleting a mentionable" do
    before(:all) do
      @mentioner = ImAMentioner.create
      @mentioner.mention!(@mentionable)
    end

    it "removes mention relationships" do
      expect(Socialization.mention_model).to receive(:remove_mentioners).with(@mentionable)
      @mentionable.destroy
    end
  end

end
