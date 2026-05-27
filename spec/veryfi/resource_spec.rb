# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe Veryfi::Resource do
  subject(:resource) { described_class.new(raw) }

  let(:raw) do
    {
      "id" => 44_691_518,
      "is_duplicate" => true,
      "vendor" => {
        "name" => "East Repair",
        "address" => "1912 Harvest Lane"
      },
      "line_items" => [
        { "id" => 101, "description" => "Brake cables", "total" => 100 },
        { "id" => 102, "description" => "Pedal arms",   "total" => 30 }
      ],
      "tags" => [],
      "notes" => nil
    }
  end

  describe "Hash compatibility (no breakage for existing callers)" do
    it "is a Hash" do
      expect(resource).to be_a(Hash)
    end

    it "supports string-key access exactly like a Hash" do
      expect(resource["id"]).to eq(44_691_518)
      expect(resource["vendor"]["name"]).to eq("East Repair")
    end

    it "supports symbol-key access transparently" do
      expect(resource[:id]).to eq(44_691_518)
      expect(resource.fetch(:vendor).fetch(:name)).to eq("East Repair")
    end

    it "supports dig with both string and symbol keys" do
      expect(resource.dig("vendor", "name")).to eq("East Repair")
    end

    it "supports key? / include? / member? / has_key? on both string and symbol" do
      expect(resource.key?("id")).to be(true)
      expect(resource.key?(:id)).to be(true)
      expect(resource.include?(:id)).to be(true)
    end

    it "compares equal to an equivalent plain Hash" do
      expect(resource).to eq(raw)
    end

    it "round-trips through JSON unchanged" do
      expect(JSON.parse(JSON.generate(resource))).to eq(raw)
    end

    it "iterates like a Hash via each_pair" do
      keys = []
      resource.each_pair { |k, _v| keys << k }
      expect(keys).to match_array(raw.keys)
    end
  end

  describe "attribute-style access" do
    it "exposes every key as a reader method" do
      expect(resource.id).to eq(44_691_518)
      expect(resource.notes).to be_nil
    end

    it "recursively wraps nested hashes" do
      expect(resource.vendor).to be_a(described_class)
      expect(resource.vendor.name).to eq("East Repair")
    end

    it "wraps each element of an array of hashes" do
      expect(resource.line_items).to all(be_a(described_class))
      expect(resource.line_items.first.description).to eq("Brake cables")
      expect(resource.line_items.map(&:total)).to eq([100, 30])
    end

    it "treats `name?` style as a truthiness predicate" do
      expect(resource.is_duplicate?).to be(true)
      expect(resource.notes?).to be(false)
    end

    it "passes leaf values through unwrapped" do
      expect(resource.id).to be_a(Integer)
      expect(resource.tags).to eq([])
    end

    it "raises NoMethodError for unknown keys (unlike OpenStruct returning nil)" do
      expect { resource.bogus_field }.to raise_error(NoMethodError)
    end

    it "respond_to? agrees with method_missing" do
      expect(resource).to respond_to(:id)
      expect(resource).to respond_to(:is_duplicate?)
      expect(resource).not_to respond_to(:bogus_field)
    end
  end

  describe ".wrap" do
    it "returns Resource for a Hash" do
      expect(described_class.wrap("id" => 1)).to be_a(described_class)
    end

    it "returns an Array of Resources for an Array of Hashes" do
      result = described_class.wrap([{ "id" => 1 }, { "id" => 2 }])
      expect(result).to all(be_a(described_class))
      expect(result.map(&:id)).to eq([1, 2])
    end

    it "passes scalars through" do
      expect(described_class.wrap(42)).to eq(42)
      expect(described_class.wrap("hello")).to eq("hello")
      expect(described_class.wrap(nil)).to be_nil
    end

    it "does not double-wrap an existing Resource" do
      r = described_class.new("id" => 1)
      expect(described_class.wrap(r)).to equal(r)
    end
  end

  describe "#to_h" do
    it "returns a plain Hash, recursively unwrapping" do
      plain = resource.to_h
      expect(plain).to be_an_instance_of(Hash)
      expect(plain["vendor"]).to be_an_instance_of(Hash)
      expect(plain["line_items"].first).to be_an_instance_of(Hash)
    end
  end
end
