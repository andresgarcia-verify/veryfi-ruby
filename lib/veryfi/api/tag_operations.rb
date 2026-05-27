# frozen_string_literal: true

module Veryfi
  module Api
    # Mix-in providing the standard per-resource tag endpoints used by
    # processed-document resources (Any Document, Bank Statement, Business
    # Card, Check, W-2, W-8, W-9). Each host must define an `ENDPOINT`
    # constant pointing at the resource collection (e.g. `"/partner/checks/"`).
    #
    # When included, the host class exposes:
    #
    #   - `#tags(id, params = {})`     → GET `…/{id}/tags`
    #   - `#add_tag(id, params)`       → PUT `…/{id}/tags`        (single)
    #   - `#add_tags(id, tags)`        → POST `…/{id}/tags`       (multiple)
    #   - `#delete_tag(id, tag_id)`    → DELETE `…/{id}/tags/{tag_id}`
    #   - `#delete_tags(id)`           → DELETE `…/{id}/tags`     (all)
    module TagOperations
      # List tags on the resource.
      #
      # @param id [Integer] resource id
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource] `{ "tags" => [...] }`
      def tags(id, params = {})
        request.get("#{self.class::ENDPOINT}#{id}/tags", params)
      end

      # Add (or link) a single tag.
      #
      # @param id [Integer] resource id
      # @param params [Hash] e.g. `{ name: "priority" }`
      # @return [Veryfi::Resource] the linked tag
      def add_tag(id, params)
        request.put("#{self.class::ENDPOINT}#{id}/tags", params)
      end

      # Add many tags in a single call.
      #
      # @param id [Integer] resource id
      # @param tags [Array<String>] tag names
      # @return [Veryfi::Resource] `{ "tags" => [...] }`
      def add_tags(id, tags)
        request.post("#{self.class::ENDPOINT}#{id}/tags", tags: tags)
      end

      # Unlink a single tag from the resource.
      #
      # @param id [Integer] resource id
      # @param tag_id [Integer]
      # @return [Veryfi::Resource]
      def delete_tag(id, tag_id)
        request.delete("#{self.class::ENDPOINT}#{id}/tags/#{tag_id}")
      end

      # Unlink every tag from the resource.
      #
      # @param id [Integer] resource id
      # @return [Veryfi::Resource]
      def delete_tags(id)
        request.delete("#{self.class::ENDPOINT}#{id}/tags")
      end
    end
  end
end
