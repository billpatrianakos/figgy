
require 'spec_helper'

describe Figgy do
  context 'pivot overlays' do
    it 'multiple pivot points exist' do
      write_config 'values', "one: 1 \nfoo: bar"
      write_config 'lang_en/values', 'one: one'
      write_config 'lang_es/values', 'one: uno'

      config = test_config do |config|
        config.define_overlay :default, nil
        config.define_pivot_overlay :language, :lang
      end

      config.values.one.should == 1
      config.values.foo.should == 'bar'
      config.language('en').values.one.should == 'one'
      config.language('en').values.foo.should == 'bar'
      config.language('es').values.one.should == 'uno'
      config.language('es').values.foo.should == 'bar'
      config.language('de').values.one.should == 1
      config.language('de').values.foo.should == 'bar'
    end
  end
end
