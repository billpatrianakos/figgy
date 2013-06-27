require 'spec_helper'

describe Figgy do
  context "hash contents" do
    it "makes the hash result dottable and indifferent" do
      write_config 'values', <<-YML
      outer:
        also: dottable
      YML

      config = test_config
      config.values.outer.should == { "also" => "dottable" }
      config.values["outer"].should == { "also" => "dottable" }
      config.values[:outer].should == { "also" => "dottable" }
    end

    it "makes a hash inside the hash result dottable and indifferent" do
      write_config 'values', <<-YML
      outer:
        also: dottable
      YML

      config = test_config
      config.values.outer.also.should == "dottable"
      config.values.outer["also"].should == "dottable"
      config.values.outer[:also].should == "dottable"
    end

    it "makes a hash inside an array result dottable and indifferent" do
      write_config 'values', <<-YML
      outer:
        - in: an
          array: it is
        - still: a dottable hash
      YML

      config = test_config
      config.values.outer.size.should == 2
      first, second = *config.values.outer

      first.should == { "in" => "an", "array" => "it is" }
      first[:in].should == "an"
      first.array.should == "it is"

      second.still.should == "a dottable hash"
      second[:still].should == "a dottable hash"
      second["still"].should == "a dottable hash"
    end

    it "supports dottable and indifferent setting" do
      write_config 'values', "number: 1"
      config = test_config
      config.values["number"] = 2
      config.values.number.should == 2
      config.values[:number] = 3
      config.values.number.should == 3
      config.values.number = 4
      config.values.number.should == 4
    end
  end
end
