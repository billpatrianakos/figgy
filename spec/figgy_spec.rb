require 'spec_helper'

describe Figgy do
  it "reads YAML config files" do
    write_config 'values', <<-YML
    foo: 1
    bar: 2
    YML

    test_config.values.should == { "foo" => 1, "bar" => 2 }
  end

  it "raises an exception if the file can't be found" do
    expect { test_config.values }.to raise_error(Figgy::FileNotFound)
  end

  it "has a useful #inspect method" do
    write_config 'values', 'foo: 1'
    write_config 'wtf', 'bar: 2'

    config = test_config
    config.inspect.should == "#<Figgy (empty)>"

    config.values
    config.inspect.should == "#<Figgy (1 keys): values>"

    config.wtf
    config.inspect.should == "#<Figgy (2 keys): values wtf>"
  end
end

describe Figgy do
  describe 'CnuConfig drop-in compatibility' do
    it "should maybe support path_formatter = some_proc.call(config_name, overlays)"
    it "should support preload's all_key_names when using path_formatter"
    it "should support preload's all_key_names when using path_formatter"
  end
end
