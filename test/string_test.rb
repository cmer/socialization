require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class StringTest < Test::Unit::TestCase
  context "#deep_const_get" do
    should "return a class" do
      assert_equal Socialization, "Socialization".deep_const_get
      assert_equal Socialization::ActiveRecordStores, "Socialization::ActiveRecordStores".deep_const_get
      assert_equal Socialization::ActiveRecordStores::Follow, "Socialization::ActiveRecordStores::Follow".deep_const_get

      assert_raise(NameError) { "Foo::Bar".deep_const_get }
    end
  end
end
