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

      figgy_config = config.instance_variable_get('@config')
      figgy_config.overlays.should == [[:default, nil],
                                       [:environment, "prod"],
                                       [:country, "US"],
                                       [:environment_country, "prod_US"]]
      config.keys.should == { "foo" => 3 }
    end

    it "reads from overlays in order of definition" do
      write_config 'values', <<-YML
      foo: 11
      bar: 11
      baz: 11
      YML

      write_config 'prod_US/values', <<-YML
      dog: 111
      YML

      write_config 'prod/values', <<-YML
      bar: 12
      baz: 12
      YML

      write_config 'development/values', <<-YML
      baz: 13
      fog: 11
      dog: 11
      YML

      write_config 'staging/values', <<-YML
      baz: 13
      dog: 12
      YML

      config = test_config do |config|
        config.define_overlay :default, nil
        config.define_overlay :environment, ['development', 'staging', 'prod']
        config.define_overlay :country, 'US'
        config.define_combined_overlay :environment, :country
      end

      figgy_config = config.instance_variable_get('@config')
      figgy_config.overlays.should == [[:default, nil],
                                       [:environment, "development"],
                                       [:environment, "staging"],
                                       [:environment, "prod"],
                                       [:country, "US"],
                                       [:environment_country, "development_US"],
                                       [:environment_country, "staging_US"],
                                       [:environment_country, "prod_US"]]
      overlay_dirs = figgy_config.overlay_dirs
      # strip location specifics
      overlay_dirs.collect! {|dir| dir.gsub(/^.*\/figgy\/tmp\//, '')}
      overlay_dirs.should == ['aruba/',
                              'aruba/development',
                              'aruba/staging',
                              'aruba/prod',
                              'aruba/US',
                              'aruba/development_US',
                              'aruba/staging_US',
                              'aruba/prod_US']
      config.values.foo.should == 11
      config.values.bar.should == 12
      config.values.baz.should == 12
      config.values.fog.should == 11
      config.values.dog.should == 111
    end

    it "combines 2 cascading overlays" do
      config = test_config do |config|
        config.define_overlay :default, nil
        config.define_overlay :environment, ['development', 'staging', 'prod']
        config.define_overlay :country, ['US', 'GB', 'AU']
        config.define_combined_overlay :environment, :country
      end

      figgy_config = config.instance_variable_get('@config')
      figgy_config.overlays.should == [[:default, nil],
                                       [:environment, "development"],
                                       [:environment, "staging"],
                                       [:environment, "prod"],
                                       [:country, "US"],
                                       [:country, "GB"],
                                       [:country, "AU"],
                                       [:environment_country, "development_US"],
                                       [:environment_country, "development_GB"],
                                       [:environment_country, "development_AU"],
                                       [:environment_country, "staging_US"],
                                       [:environment_country, "staging_GB"],
                                       [:environment_country, "staging_AU"],
                                       [:environment_country, "prod_US"],
                                       [:environment_country, "prod_GB"],
                                       [:environment_country, "prod_AU"]]
      overlay_dirs = figgy_config.overlay_dirs
      # strip location specifics
      overlay_dirs.collect! {|dir| dir.gsub(/^.*\/figgy\/tmp\//, '')}
      overlay_dirs.should == ['aruba/',
                              'aruba/development',
                              'aruba/staging',
                              'aruba/prod',
                              'aruba/US',
                              'aruba/GB',
                              'aruba/AU',
                              'aruba/development_US',
                              'aruba/development_GB',
                              'aruba/development_AU',
                              'aruba/staging_US',
                              'aruba/staging_GB',
                              'aruba/staging_AU',
                              'aruba/prod_US',
                              'aruba/prod_GB',
                              'aruba/prod_AU']
    end
  end
end
