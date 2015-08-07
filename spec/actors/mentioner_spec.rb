require 'spec_helper'

describe Socialization::Mentioner do
  before(:all) do
    use_ar_store
    @mentioner = ImAMentioner.new
    @mentionable = ImAMentionable.create
  end

  describe "#is_mentioner?" do
    it "returns true" do
      expect(@mentioner.is_mentioner?).to be true
    end
  end

  describe "#mentioner?" do
    it "returns true" do
      expect(@mentioner.mentioner?).to be true
    end
  end

  describe "#mention!" do
    it "does not accept non-mentionables" do
      expect { @mentioner.mention!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Mention.mention!" do
      expect($Mention).to receive(:mention!).with(@mentioner, @mentionable).once
      @mentioner.mention!(@mentionable)
    end
  end

  describe "#unmention!" do
    it "does not accept non-mentionables" do
      expect { @mentioner.unmention!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Mention.mention!" do
      expect($Mention).to receive(:unmention!).with(@mentioner, @mentionable).once
      @mentioner.unmention!(@mentionable)
    end
  end

  describe "#toggle_mention!" do
    it "does not accept non-mentionables" do
      expect { @mentioner.unmention!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "unmentions when mentioning" do
      expect(@mentioner).to receive(:mentions?).with(@mentionable).once.and_return(true)
      expect(@mentioner).to receive(:unmention!).with(@mentionable).once
      @mentioner.toggle_mention!(@mentionable)
    end

    it "mentions when not mentioning" do
      expect(@mentioner).to receive(:mentions?).with(@mentionable).once.and_return(false)
      expect(@mentioner).to receive(:mention!).with(@mentionable).once
      @mentioner.toggle_mention!(@mentionable)
    end
  end

  describe "#mentions?" do
    it "does not accept non-mentionables" do
      expect { @mentioner.unmention!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Mention.mentions?" do
      expect($Mention).to receive(:mentions?).with(@mentioner, @mentionable).once
      @mentioner.mentions?(@mentionable)
    end
  end

  describe "#mentionables" do
    it "calls $Mention.mentionables" do
      expect($Mention).to receive(:mentionables).with(@mentioner, @mentionable.class, { :foo => :bar })
      @mentioner.mentionables(@mentionable.class, { :foo => :bar })
    end
  end

  describe "#mentionees" do
    it "calls $Mention.mentionables" do
      expect($Mention).to receive(:mentionables).with(@mentioner, @mentionable.class, { :foo => :bar })
      @mentioner.mentionees(@mentionable.class, { :foo => :bar })
    end
  end

  describe "#mentionables_relation" do
    it "calls $Mention.mentionables_relation" do
      expect($Mention).to receive(:mentionables_relation).with(@mentioner, @mentionable.class, { :foo => :bar })
      @mentioner.mentionables_relation(@mentionable.class, { :foo => :bar })
    end
  end

  describe "#mentionees_relation" do
    it "calls $Mention.mentionables_relation" do
      expect($Mention).to receive(:mentionables_relation).with(@mentioner, @mentionable.class, { :foo => :bar })
      @mentioner.mentionees_relation(@mentionable.class, { :foo => :bar })
    end
  end

  it "removes mention relationships" do
    expect(Socialization.mention_model).to receive(:remove_mentionables).with(@mentioner)
    @mentioner.destroy
  end
end
