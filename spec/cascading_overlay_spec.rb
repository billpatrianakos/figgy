require 'spec_helper'

describe Figgy do
  context "cascading overlays" do
    it "reads from overlays in order of definition" do
      write_config 'values', <<-YML
      foo: 1
      bar: 1
      baz: 1
      YML

      write_config 'prod/values', <<-YML

      bar: 2
      baz: 2
      YML

      write_config 'development/values', <<-YML
      baz: 3
      fog: 1
      dog: 1
      YML

      write_config 'staging/values', <<-YML
      baz: 3
      dog: 2
      YML

      config = test_config do |config|
        config.define_overlay :default, nil
        config.define_overlay :environment, ['development', 'staging', 'prod']
      end

      config.values.foo.should == 1
      config.values.bar.should == 2
      config.values.baz.should == 2
      config.values.fog.should == 1
      config.values.dog.should == 2
    end
  end
end
