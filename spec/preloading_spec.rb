require 'spec_helper'

describe Figgy do
  context "preloading" do
    it "can preload all available configs when config.preload = true" do
      write_config 'values', 'foo: 1'
      write_config 'prod/values', 'foo: 2'
      write_config 'prod/prod_only', 'bar: baz'

      config = test_config do |config|
        config.define_overlay :default, nil
        config.define_overlay :environment, 'prod'
        config.preload = true
      end

      write_config 'prod/values', 'foo: 3'
      write_config 'prod_only', 'bar: quux'

      config.values['foo'].should == 2
      config.prod_only['bar'].should == 'baz'
    end

    it "still works with multiple extension support" do
      write_config 'values.yaml', 'foo: 1'
      write_config 'values.json', '{ "foo": 2 }'
      write_config 'prod/lonely.yml', 'only: yml'
      write_config 'local/json_values.json', '{ "json": true }'

      config = test_config do |config|
        config.define_overlay :default, nil
        config.define_overlay :environment, 'prod'
        config.define_overlay :local, 'local'
      end

      finder = config.instance_variable_get(:@finder)
      finder.all_key_names.should == ['values', 'lonely', 'json_values']
    end

    it "still supports reloading when preloading is enabled" do
      write_config 'values', 'foo: 1'

      config = test_config do |config|
        config.preload = true
        config.always_reload = true
      end

      config.values['foo'].should == 1

      write_config 'values', 'foo: 2'
      config.values['foo'].should == 2
    end
  end
end
