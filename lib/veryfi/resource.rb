# frozen_string_literal: true

module Veryfi
  # A lightweight, dependency-free wrapper around an API response payload.
  #
  # `Resource` inherits from `Hash`, so anything that already treats the
  # response as a hash keeps working unchanged:
  #
  #   response["id"]            # => 44691518
  #   response.dig("vendor", "name")
  #   response.is_a?(Hash)      # => true
  #   JSON.pretty_generate(response)
  #
  # In addition, every key is also accessible as a method, recursively:
  #
  #   response.id               # => 44691518
  #   response.vendor.name      # => "East Repair"
  #   response.line_items.first.description
  #   response.is_duplicate?    # => truthiness of self["is_duplicate"]
  #
  # Nested hashes are wrapped into Resources, and arrays of hashes become
  # arrays of Resources. Other values (strings, numbers, booleans, nil)
  # pass through untouched. Both string (`"id"`) and symbol (`:id`) keys
  # work transparently.
  class Resource < ::Hash
    # Wrap any value coming back from the API. Hashes become Resources,
    # arrays are mapped recursively, and everything else passes through.
    #
    # @param value [Object] raw value from `JSON.parse`
    # @return [Object] wrapped value
    def self.wrap(value)
      return value if value.is_a?(Resource)

      case value
      when ::Hash  then new(value)
      when ::Array then value.map { |v| wrap(v) }
      else              value
      end
    end

    def initialize(hash = {})
      super()
      hash.each_pair { |key, value| self[key.to_s] = Resource.wrap(value) }
    end

    def [](key)
      super(key.to_s)
    end

    def fetch(key, *args, &block)
      super(key.to_s, *args, &block)
    end

    def key?(key)
      super(key.to_s)
    end
    alias has_key? key?
    alias include? key?
    alias member? key?

    # Returns a plain (unwrapped) `Hash` representation, recursively.
    # Useful when you need to hand the data off to something that explicitly
    # expects a plain Hash (e.g. some serializers).
    #
    # @return [Hash]
    def to_h
      each_with_object({}) do |(key, value), memo|
        memo[key] = unwrap(value)
      end
    end
    alias to_hash to_h

    def respond_to_missing?(name, include_private = false)
      string_name = name.to_s.chomp("?")
      key?(string_name) || super
    end

    def method_missing(name, *args, &block)
      string_name = name.to_s
      bare_name = string_name.chomp("?")

      if args.empty? && block.nil? && key?(bare_name)
        value = self[bare_name]
        string_name.end_with?("?") ? !value.nil? && value != false : value
      else
        super
      end
    end

    private

    def unwrap(value)
      case value
      when Resource then value.to_h
      when ::Array  then value.map { |v| v.is_a?(Resource) ? v.to_h : v }
      else               value
      end
    end
  end
end
