# frozen_string_literal: true

module Veryfi
  module Api
    # W-2 splitting endpoints (`/partner/w2s-set/`).
    #
    # Use these when you have a single file containing multiple W-2 forms.
    # Veryfi will split it and process each W-2 separately; you receive a
    # collection that references the individual {W2} ids it produced.
    #
    # @see https://docs.veryfi.com/api/split-and-process-a-w-2/
    class W2Split
      include FilePayload

      ENDPOINT = "/partner/w2s-set/"

      attr_reader :request

      def initialize(request)
        @request = request
      end

      # List previously processed W-2 sets.
      #
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource]
      def all(params = {})
        request.get(ENDPOINT, params)
      end

      # Fetch a single W-2 set by id.
      #
      # @param id [Integer]
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource]
      def get(id, params = {})
        request.get("#{ENDPOINT}#{id}/", params)
      end

      # Upload a multi-W-2 file and split-and-process it.
      #
      # @param raw_params [Hash]
      # @option raw_params [String] :file_path **required.** Local path.
      # @option raw_params [String] :file_name (basename of `:file_path`)
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
      # @option raw_params [Array<String>] :file_urls  list of URLs (alternative)
      # @option raw_params [Integer]       :max_pages_to_process (`nil` = all pages)
      # @return [Veryfi::Resource]
      def process_url(raw_params)
        request.post(ENDPOINT, raw_params.transform_keys(&:to_sym))
      end
    end
  end
end
