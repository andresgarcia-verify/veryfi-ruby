# frozen_string_literal: true

module Veryfi
  module Api
    # Tags on a specific document (`/partner/documents/{id}/tags/`).
    #
    # @see https://docs.veryfi.com/api/receipts-invoices/get-document-tags/
    class DocumentTag
      attr_reader :request

      def initialize(request)
        @request = request
      end

      # List tags on a document.
      #
      # @param document_id [Integer]
      # @param params [Hash] optional query-string parameters
      # @return [Array<Veryfi::Resource>] the `"tags"` array from the response
      def all(document_id, params = {})
        response = request.get("/partner/documents/#{document_id}/tags/", params)

        response["tags"]
      end

      # Add a single tag to a document. (PUT semantics — creates the tag if
      # it does not exist, otherwise links the existing tag.)
      #
      # @param document_id [Integer]
      # @param params [Hash]
      # @option params [String] :name **required.** Tag name.
      # @return [Veryfi::Resource] the linked tag
      def add(document_id, params)
        request.put("/partner/documents/#{document_id}/tags/", params)
      end

      # Add many tags to a document in a single call.
      #
      # @param document_id [Integer]
      # @param tags [Array<String>] tag names
      # @return [Veryfi::Resource] `{ "tags" => [...] }`
      def add_multiple(document_id, tags)
        request.post("/partner/documents/#{document_id}/tags/", tags: tags)
      end

      # Replace the entire tag list on a document (PUT on the parent
      # resource with a `tags:` array).
      #
      # @param document_id [Integer]
      # @param tags [Array<String>] new full list of tag names
      # @return [Veryfi::Resource] the updated document
      def replace(document_id, tags)
        request.put("/partner/documents/#{document_id}/", tags: tags)
      end

      # Unlink every tag from a document.
      #
      # @param document_id [Integer]
      # @return [Veryfi::Resource]
      def delete_all(document_id)
        request.delete("/partner/documents/#{document_id}/tags/")
      end

      # Unlink a single tag from a document.
      #
      # @param document_id [Integer]
      # @param id [Integer] tag id
      # @return [Veryfi::Resource]
      def delete(document_id, id)
        request.delete("/partner/documents/#{document_id}/tags/#{id}")
      end
    end
  end
end
