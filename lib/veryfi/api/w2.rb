# frozen_string_literal: true

module Veryfi
  module Api
    # W-2 endpoints (`/partner/w2s/`).
    #
    # @see https://docs.veryfi.com/api/w2s/
    class W2
      include FilePayload
      include TagOperations

      ENDPOINT = "/partner/w2s/"

      attr_reader :request

      def initialize(request)
        @request = request
      end

      # List previously processed W-2 documents.
      #
      # @param params [Hash] optional query-string parameters
      # @option params [String]  :created_date__gt   "YYYY-MM-DD HH:MM:SS" — strictly after
      # @option params [String]  :created_date__gte  after or equal
      # @option params [String]  :created_date__lt   strictly before
      # @option params [String]  :created_date__lte  before or equal
      # @option params [Integer] :page               (1)
      # @option params [Integer] :page_size          (50)
      # @return [Veryfi::Resource] `{ "documents" => [...] }`
      def all(params = {})
        request.get(ENDPOINT, params)
      end

      # Fetch a single W-2 by id.
      #
      # @param id [Integer]
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource]
      def get(id, params = {})
        request.get("#{ENDPOINT}#{id}/", params)
      end

      # Upload a W-2 file and extract its fields.
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
      # @option raw_params [String] :file_url  **required.**
      # @option raw_params [String] :file_name (basename of `:file_url`)
      # @return [Veryfi::Resource]
      def process_url(raw_params)
        params = raw_params.transform_keys(&:to_sym)
        params[:file_name] ||= File.basename(params[:file_url]) if params[:file_url]

        request.post(ENDPOINT, params)
      end

      # Update writable fields on a processed W-2.
      #
      # @param id [Integer]
      # @param params [Hash]
      # @return [Veryfi::Resource]
      def update(id, params)
        request.put("#{ENDPOINT}#{id}/", params)
      end

      # Delete a W-2.
      #
      # @param id [Integer]
      # @return [Veryfi::Resource]
      def delete(id)
        request.delete("#{ENDPOINT}#{id}/")
      end
    end
  end
end
