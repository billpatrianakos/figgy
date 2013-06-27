require 'spec_helper'

describe Figgy do
  context "reloading" do
    it "can reload on each access when config.always_reload = true" do
      write_config 'values', 'foo: 1'
      config = test_config do |config|
        config.always_reload = true
      end
      config.values.should == { "foo" => 1 }

      write_config 'values', 'foo: bar'
      config.values.should == { "foo" => "bar" }
    end

    it "does not reload when config.always_reload = false" do
      write_config 'values', 'foo: 1'
      config = test_config do |config|
        config.always_reload = false
      end
      config.values.should == { "foo" => 1 }

      write_config 'values', 'foo: bar'
      config.values.should == { "foo" => 1 }
    end
  end
end
