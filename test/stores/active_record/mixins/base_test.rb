require File.expand_path(File.dirname(__FILE__))+'/../../../test_helper'

class ActiveRecordBaseStoreTest < Test::Unit::TestCase
  context ".update_counter" do
    should "increment counter cache if column exists" do
      followable = ImAFollowableWithCounterCache.create

      update_counter(followable, followers_count: +1)

      assert_equal 1, followable.reload.followers_count
    end

    should "not raise any errors if column doesn't exist" do
      followable = ImAFollowable.create

      assert_nothing_raised do
        update_counter(followable, followers_count: +1)
      end
    end
  end

  def update_counter(model, counter)
    klass = Object.new
    klass.extend(Socialization::ActiveRecordStores::Mixins::Base)
    klass.update_counter(model, counter)
  end
end

