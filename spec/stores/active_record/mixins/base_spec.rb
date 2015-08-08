require 'spec_helper'

describe Socialization::ActiveRecordStores::Mixins::Base do
  describe ".update_counter" do
    it "increments counter cache if column exists" do
      followable = ImAFollowableWithCounterCache.create

      update_counter(followable, followers_count: +1)

      expect(followable.reload.followers_count).to eq(1)
    end

    it "does not raise any errors if column doesn't exist" do
      followable = ImAFollowable.create
      update_counter(followable, followers_count: +1)
    end
  end

  def update_counter(model, counter)
    klass = Object.new
    klass.extend(Socialization::ActiveRecordStores::Mixins::Base)
    klass.update_counter(model, counter)
  end
end

