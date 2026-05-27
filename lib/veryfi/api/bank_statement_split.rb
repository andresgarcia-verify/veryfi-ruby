# frozen_string_literal: true

module Veryfi
  module Api
    # Bank-statement splitting endpoints (`/partner/bank-statements-set/`).
    #
    # Use these when you have a single file containing multiple bank
    # statements (e.g. an annual archive PDF). Veryfi will split the file
    # and process each statement separately; you receive a collection that
    # references the individual {BankStatement} ids it produced.
    class BankStatementSplit
      include FilePayload

      ENDPOINT = "/partner/bank-statements-set/"

      attr_reader :request

      def initialize(request)
        @request = request
      end

      # List previously processed bank-statement sets.
      #
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource]
      def all(params = {})
        request.get(ENDPOINT, params)
      end

      # Fetch a single bank-statement set by id.
      #
      # @param id [Integer]
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource]
      def get(id, params = {})
        request.get("#{ENDPOINT}#{id}", params)
      end

      # Upload a multi-statement file and split-and-process it.
      #
      # @param raw_params [Hash]
      # @option raw_params [String] :file_path  **required.** Local path.
      # @option raw_params [String] :file_name  (basename of `:file_path`)
      # @return [Veryfi::Resource]
      def process(raw_params)
        params = raw_params.transform_keys(&:to_sym)
        file_path = params.delete(:file_path)
        file_name = params.delete(:file_name)

        payload = file_payload(file_path, file_name).merge(params)

        request.post(ENDPOINT, payload)
      end

      # URL variant of {#process}.
      #
      # @param raw_params [Hash]
      # @option raw_params [String]        :file_url   single URL
      # @option raw_params [Array<String>] :file_urls  list of URLs (alternative to `:file_url`)
      # @return [Veryfi::Resource]
      def process_url(raw_params)
        request.post(ENDPOINT, raw_params.transform_keys(&:to_sym))
      end
    end
  end
end
