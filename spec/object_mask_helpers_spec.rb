#--
# Copyright (c) 2014 SoftLayer Technologies, Inc. All rights reserved.
#
# For licensing information see the LICENSE.md file in the project root.
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

require 'rubygems'
require 'softlayer_api'
require 'rspec'

describe String, "#_to_sl_object_mask_property" do
  it "converts to the string itself" do
    expect("blah"._to_sl_object_mask_property).to eql("blah")
    expect(" blah"._to_sl_object_mask_property).to eql("blah")
    expect(" blah "._to_sl_object_mask_property).to eql("blah")
    expect(" blah \t\n"._to_sl_object_mask_property).to eql("blah")
  end

  it "echos the empty string" do
    expect(""._to_sl_object_mask_property).to eql("")
  end
end

describe Array,"#_to_sl_object_mask_property" do
  it "converts an empty array to the empty string" do
    expect([]._to_sl_object_mask_property).to eql("")
  end

  it "handles simple arrays" do
    expect(["foo", "bar", "baz"]._to_sl_object_mask_property).to eql("foo,bar,baz")
  end

  it "flattens inner arrays to simple lists" do
    expect(["foo", ["bar", "baz"]]._to_sl_object_mask_property).to eql("foo,bar,baz")
  end

  it "handles nils in the array" do
    expect(["foo", nil, "bar"]._to_sl_object_mask_property()).to eql("foo,bar")
  end
end

describe Hash, "#_to_sl_object_mask_property" do
  it "returns the empty string for an empty hash" do
      expect({}._to_sl_object_mask_property).to eql("")
  end

  it "constructs a dot expression for a simple string value" do
    expect({"foo" => "foobar"}._to_sl_object_mask_property).to eql("foo.foobar")
  end

  it "builds a bracket expression with array values" do
    expect({"foo" => ["one", "two", "three"]}._to_sl_object_mask_property).to eql("foo[one,two,three]")
  end

  it "builds bracket expressions for nested hashes" do
    expect({"foo" => {"sub" => "resub"}}._to_sl_object_mask_property).to eql("foo[sub.resub]")
  end

  it "resolves simple inner values to simple dot expressions" do
    expect({"top" => [ "middle1", {"middle2" => "end"}]}._to_sl_object_mask_property).to eql("top[middle1,middle2.end]")
  end

  it "accepts an inner empty hash and returns a mask" do
    expect({ "ipAddress" => { "ipAddress" => {}}}._to_sl_object_mask_property).to eql("ipAddress[ipAddress]")
  end
end

describe Hash, "#to_sl_object_mask" do
  it "rejects the empty hash" do
      expect { {}.to_sl_object_mask }.to raise_error(RuntimeError)
  end

  it "constructs a dot expression for a simple string value" do
    expect({"mask" => "foobar"}.to_sl_object_mask).to eql("mask.foobar")
  end

  it "builds a bracket expression with array values" do
    expect({"mask" => ["one", "two", "three"]}.to_sl_object_mask).to eql("mask[one,two,three]")
  end

  it "builds bracket expressions for nested hashes" do
    expect({"mask(some_type)" => {"sub" => "resub"}}.to_sl_object_mask).to eql("mask(some_type)[sub.resub]")
  end

  it "resolves simple inner values to simple dot expressions" do
    expect({"mask" => [ "middle1", {"middle2" => "end"}]}.to_sl_object_mask).to eql("mask[middle1,middle2.end]")
  end

  it "accepts an inner empty hash and returns a mask" do
    expect({ "mask" => { "ipAddress" => {}}}.to_sl_object_mask).to eql("mask[ipAddress]")
  end

  it "converts masks with different roots" do
    object_mask = { "mask" => { "ipAddress" => {}},
      "mask(duck_type)" => {"webbed" => "feet"}}.to_sl_object_mask

      expect(["[mask[ipAddress],mask(duck_type)[webbed.feet]]", "mask(duck_type)[webbed.feet],[mask[ipAddress]]"].find(object_mask)).to_not be_nil
  end
end
