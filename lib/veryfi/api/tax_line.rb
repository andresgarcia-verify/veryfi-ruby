# frozen_string_literal: true

module Veryfi
  module Api
    # Tax lines on a processed document
    # (`/partner/documents/{id}/tax-lines`).
    #
    # Most documents have at most a handful of tax lines (e.g. one for state
    # sales tax, one for local). This namespace lets you list, add, edit
    # and remove them on demand.
    class TaxLine
      attr_reader :request

      def initialize(request)
        @request = request
      end

      # List the tax lines for a document.
      #
      # @param document_id [Integer]
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource] `{ "tax_lines" => [...] }`
      def all(document_id, params = {})
        request.get("/partner/documents/#{document_id}/tax-lines", params)
      end

      # Create a tax line on a document.
      #
      # @param document_id [Integer]
      # @param params [Hash]
      # @option params [String]  :name   **required.** e.g. "Sales Tax".
      # @option params [Numeric] :rate   Tax rate (%).
      # @option params [Numeric] :base   Taxable base amount.
      # @option params [Numeric] :total  Tax amount.
      # @option params [Integer] :order  Display order (0-indexed).
      # @return [Veryfi::Resource] the created tax line
      def create(document_id, params)
        request.post("/partner/documents/#{document_id}/tax-lines", params)
      end

      # Fetch a single tax line.
      #
      # @param document_id [Integer]
      # @param id [Integer]
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource]
      def get(document_id, id, params = {})
        request.get("/partner/documents/#{document_id}/tax-lines/#{id}", params)
      end

      # Update a tax line.
      #
      # @param document_id [Integer]
      # @param id [Integer]
      # @param params [Hash] writable fields you want to change
      # @return [Veryfi::Resource]
      def update(document_id, id, params)
        request.put("/partner/documents/#{document_id}/tax-lines/#{id}", params)
      end

      # Delete a tax line.
      #
      # @param document_id [Integer]
      # @param id [Integer]
      # @return [Veryfi::Resource]
      def delete(document_id, id)
        request.delete("/partner/documents/#{document_id}/tax-lines/#{id}")
      end
    end
  end
end
