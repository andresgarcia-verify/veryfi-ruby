# frozen_string_literal: true

module Veryfi
  module Api
    # Checks endpoints (`/partner/checks/` and
    # `/partner/check-with-document/` for combined check + remittance
    # extraction).
    #
    # @see https://docs.veryfi.com/api/checks/
    class Check
      include FilePayload
      include TagOperations

      ENDPOINT = "/partner/checks/"
      REMITTANCE_ENDPOINT = "/partner/check-with-document/"
      ASYNC_ENDPOINT = "/partner/checks/async"

      attr_reader :request

      def initialize(request)
        @request = request
      end

      # List previously processed checks.
      #
      # @param params [Hash] optional query-string parameters
      # @option params [String]  :created_date__gt    "YYYY-MM-DD HH:MM:SS" — strictly after
      # @option params [String]  :created_date__gte   after or equal
      # @option params [String]  :created_date__lt    strictly before
      # @option params [String]  :created_date__lte   before or equal
      # @option params [Integer] :page                (1)
      # @option params [Integer] :page_size           (50)
      # @return [Veryfi::Resource] `{ "documents" => [...] }`
      def all(params = {})
        request.get(ENDPOINT, params)
      end

      # Fetch a single check by id.
      #
      # @param id [Integer]
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource]
      def get(id, params = {})
        request.get("#{ENDPOINT}#{id}/", params)
      end

      # Upload a check image and extract its fields.
      #
      # @param raw_params [Hash]
      # @option raw_params [String] :file_path **required.** Local path.
      # @option raw_params [String] :file_name (basename of `:file_path`)
      # @return [Veryfi::Resource]
      def process(raw_params)
        request.post(ENDPOINT, build_file_payload(raw_params))
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

      # Process a check together with its remittance/stub document.
      # Veryfi will OCR both halves and return a single combined response.
      #
      # @see https://docs.veryfi.com/api/checks/process-a-check-with-remittance/
      #
      # @param raw_params [Hash]
      # @option raw_params [String] :file_path **required.**
      # @option raw_params [String] :file_name (basename of `:file_path`)
      # @return [Veryfi::Resource]
      def process_with_remittance(raw_params)
        request.post(REMITTANCE_ENDPOINT, build_file_payload(raw_params))
      end

      # URL variant of {#process_with_remittance}.
      def process_with_remittance_url(raw_params)
        request.post(REMITTANCE_ENDPOINT, raw_params.transform_keys(&:to_sym))
      end

      # Async variant of {#process} — returns immediately while Veryfi
      # processes the check in the background.
      def process_async(raw_params)
        request.post(ASYNC_ENDPOINT, build_file_payload(raw_params))
      end

      # Async variant of {#process_url}.
      def process_url_async(raw_params)
        request.post(ASYNC_ENDPOINT, raw_params.transform_keys(&:to_sym))
      end

      # Update writable fields on a processed check.
      #
      # @example
      #   client.check.update(check_id, notes: "needs review")
      #
      # @param id [Integer]
      # @param params [Hash]
      # @return [Veryfi::Resource]
      def update(id, params)
        request.put("#{ENDPOINT}#{id}/", params)
      end

      # Delete a check.
      #
      # @param id [Integer]
      # @return [Veryfi::Resource]
      def delete(id)
        request.delete("#{ENDPOINT}#{id}/")
      end

      private

      def build_file_payload(raw_params)
        params = raw_params.transform_keys(&:to_sym)
        file_path = params.delete(:file_path)
        file_name = params.delete(:file_name)

        file_payload(file_path, file_name).merge(params)
      end
    end
  end
end
