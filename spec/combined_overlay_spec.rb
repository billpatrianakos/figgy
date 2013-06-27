require 'spec_helper'

describe Figgy do
  context "combined overlays" do
    it "allows new overlays to be defined from the values of others" do
      write_config 'keys', "foo: 1"
      write_config 'prod/keys', "foo: 2"
      write_config 'prod_US/keys', "foo: 3"

      config = test_config do |config|
        config.define_overlay :default, nil
        config.define_overlay :environment, 'prod'
        config.define_overlay :country, 'US'
        config.define_combined_overlay :environment, :country
      end

      config.keys.should == { "foo" => 3 }
    end
  end
end
