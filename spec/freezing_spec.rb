require 'spec_helper'

describe Figgy do
  context "freezing" do
    it "leaves results unfrozen by default", :exclude_ruby => 2.0 do
      write_config 'values', 'foo: 1'
      test_config.values.foo.should_not be_frozen
    end

    it "freezes the results when config.freeze = true" do
      write_config 'values', 'foo: 1'
      config = test_config do |config|
        config.freeze = true
      end
      config.values.should be_frozen
    end

    it "freezes all the way down" do
      write_config 'values', <<-YML
      outer:
        key: value
        array:
          - some string
          - another string
          - and: an inner hash
      YML

      config = test_config do |config|
        config.freeze = true
      end

      expect { config.values.outer.array[2]['and'] = 'foo' }.to raise_error(/can't modify frozen/)
      assert_deeply_frozen(config.values)
    end

    def assert_deeply_frozen(obj)
      obj.should be_frozen
      case obj
      when Hash then obj.each { |k, v| assert_deeply_frozen(k); assert_deeply_frozen(v) }
      when Array then obj.each { |v| assert_deeply_frozen(v) }
      end
    end
  end
end
