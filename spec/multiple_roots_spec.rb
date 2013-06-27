require 'spec_helper'

describe Figgy do
  context "multiple roots" do
    it "can be told to read from multiple directories" do
      write_config 'root1/values', 'foo: 1'
      write_config 'root2/values', 'bar: 2'

      config = test_config do |config|
        config.root = File.join(current_dir, 'root1')
        config.add_root File.join(current_dir, 'root2')
      end

      config.values.foo.should == 1
      config.values.bar.should == 2
    end

    it "supports overlays in each root" do
      write_config 'root1/values',      'foo: 1'
      write_config 'root1/prod/values', 'foo: 2'
      write_config 'root2/values',      'bar: 1'
      write_config 'root2/prod/values', 'bar: 2'

      config = test_config do |config|
        config.root = File.join(current_dir, 'root1')
        config.add_root File.join(current_dir, 'root2')
        config.define_overlay :environment, 'prod'
      end

      config.values.foo.should == 2
      config.values.bar.should == 2
    end

    it "reads from roots in *reverse* order of definition" do
      write_config 'root1/values', 'foo: 1'
      write_config 'root1/prod/values', 'foo: 2'
      write_config 'root2/prod/values', 'foo: 3'

      config = test_config do |config|
        config.root = File.join(current_dir, 'root1')
        config.add_root File.join(current_dir, 'root2')
        config.define_overlay :environment, 'prod'
      end

      config.values.foo.should == 2
    end
  end
end
