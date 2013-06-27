require 'spec_helper'

describe Figgy do
  context "multiple extensions" do
    it "supports .yaml" do
      write_config 'values.yaml', 'foo: 1'
      test_config.values.foo.should == 1
    end

    it "supports .yml.erb and .yaml.erb" do
      write_config 'values.yml.erb', '<%= "foo" %>: <%= 1 %>'
      write_config 'values.yaml.erb', '<%= "foo" %>: <%= 2 %>'
      test_config.values.foo.should == 2
    end

    it "supports .json" do
      write_config "values.json", '{ "json": true }'
      test_config.values.json.should be_true
    end

    it "loads in the order named" do
      write_config 'values.yml', 'foo: 1'
      write_config 'values.yaml', 'foo: 2'

      config = test_config do |config|
        config.define_handler('yml', 'yaml') { |body| YAML.load(body) }
      end
      config.values.foo.should == 2
    end
  end
end
