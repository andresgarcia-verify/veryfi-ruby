# frozen_string_literal: true

module Veryfi
  module Api
    # Line items on a processed document (`/partner/documents/{id}/line-items/`).
    #
    # @see https://docs.veryfi.com/api/receipts-invoices/get-document-line-items/
    class LineItem
      attr_reader :request

      def initialize(request)
        @request = request
      end

      # List all line items on a document.
      #
      # @param document_id [Integer]
      # @param params [Hash] optional query-string parameters
      # @return [Array<Veryfi::Resource>] line items (the `"line_items"` array from the response)
      def all(document_id, params = {})
        response = request.get("/partner/documents/#{document_id}/line-items/", params)
        response["line_items"]
      end

      # Add a line item to an existing document.
      #
      # @see https://docs.veryfi.com/api/receipts-invoices/create-a-line-item/
      #
      # @param document_id [Integer]
      # @param params [Hash] line-item body. Common fields:
      # @option params [String]  :description     **required.** Free-text description.
      # @option params [Numeric] :total           **required.** Line total.
      # @option params [Numeric] :quantity        (`1`)
      # @option params [Numeric] :price           Unit price.
      # @option params [Numeric] :tax             Tax amount.
      # @option params [Numeric] :tax_rate        Tax rate (%).
      # @option params [Numeric] :discount        Discount amount.
      # @option params [String]  :sku             SKU / product code.
      # @option params [String]  :type            "product" / "service" / "fuel" / ...
      # @option params [String]  :unit_of_measure
      # @option params [Integer] :order           Display order (0-indexed).
      # @return [Veryfi::Resource] the created line item
      def create(document_id, params)
        request.post("/partner/documents/#{document_id}/line-items/", params)
      end

      # Fetch a single line item.
      #
      # @param document_id [Integer]
      # @param id [Integer] line item id
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource]
      def get(document_id, id, params = {})
        request.get("/partner/documents/#{document_id}/line-items/#{id}", params)
      end

      # Update a line item.
      #
      # @see https://docs.veryfi.com/api/receipts-invoices/update-a-line-item/
      #
      # @param document_id [Integer]
      # @param id [Integer]
      # @param params [Hash] writable fields you want to change
      # @return [Veryfi::Resource] the updated line item
      def update(document_id, id, params)
        request.put("/partner/documents/#{document_id}/line-items/#{id}", params)
      end

      # Delete a single line item.
      #
      # @param document_id [Integer]
      # @param id [Integer]
      # @return [Veryfi::Resource] `{ "status" => "ok", "message" => "..." }`
      def delete(document_id, id)
        request.delete("/partner/documents/#{document_id}/line-items/#{id}")
      end

      # Delete every line item on a document.
      #
      # @see https://docs.veryfi.com/api/receipts-invoices/delete-all-document-line-items/
      #
      # @param document_id [Integer]
      # @return [Veryfi::Resource]
      def delete_all(document_id)
        request.delete("/partner/documents/#{document_id}/line-items")
      end
    end
  end
end
