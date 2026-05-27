# frozen_string_literal: true

module Veryfi
  module Api
    # PDF splitting endpoints (`/partner/documents-set/`).
    #
    # Use these when you have a single PDF containing multiple receipts /
    # invoices. Veryfi will split it and process each page as its own
    # {Document}; you receive a collection that references the individual
    # document ids it produced.
    #
    # @see https://docs.veryfi.com/api/receipts-invoices/split-and-process-a-pdf/
    class PdfSplit
      include FilePayload

      ENDPOINT = "/partner/documents-set/"

      attr_reader :request

      def initialize(request)
        @request = request
      end

      # List previously processed document sets.
      #
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource]
      def all(params = {})
        request.get(ENDPOINT, params)
      end

      # Fetch a single document set by id.
      #
      # @param id [Integer]
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource]
      def get(id, params = {})
        request.get("#{ENDPOINT}#{id}", params)
      end

      # Upload a multi-document PDF and split-and-process it.
      #
      # @param raw_params [Hash]
      # @option raw_params [String]        :file_path  **required.** Local path.
      # @option raw_params [String]        :file_name  (basename of `:file_path`)
      # @option raw_params [Array<String>] :categories (`[]`) Restrict categorization to these values.
      # @return [Veryfi::Resource]
      def process(raw_params)
        params = raw_params.transform_keys(&:to_sym)
        file_path = params.delete(:file_path)
        file_name = params.delete(:file_name)
        params[:categories] ||= []

        payload = file_payload(file_path, file_name).merge(params)

        request.post(ENDPOINT, payload)
      end

      # URL variant of {#process}.
      #
      # @param raw_params [Hash]
      # @option raw_params [String]        :file_url   single URL
      # @option raw_params [Array<String>] :file_urls  list of URLs (alternative to `:file_url`)
      # @option raw_params [Array<String>] :categories (`[]`)
      # @option raw_params [Integer]       :max_pages_to_process (`nil`)
      # @return [Veryfi::Resource]
      def process_url(raw_params)
        params = raw_params.transform_keys(&:to_sym)
        params[:categories] ||= []

        request.post(ENDPOINT, params)
      end
    end
  end
end
