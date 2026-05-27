# frozen_string_literal: true

module Veryfi
  module Api
    # Business Cards endpoints (`/partner/business-cards/`).
    #
    # @see https://docs.veryfi.com/api/business-cards/
    class BusinessCard
      include FilePayload
      include TagOperations

      ENDPOINT = "/partner/business-cards/"

      attr_reader :request

      def initialize(request)
        @request = request
      end

      # List previously processed business cards.
      #
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource] `{ "documents" => [...] }`
      def all(params = {})
        request.get(ENDPOINT, params)
      end

      # Fetch a single business card by id.
      #
      # @param id [Integer]
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource]
      def get(id, params = {})
        request.get("#{ENDPOINT}#{id}/", params)
      end

      # Upload an image of a business card and extract its contact fields.
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

      # Update writable fields on a processed business card.
      #
      # @param id [Integer]
      # @param params [Hash] writable fields
      # @return [Veryfi::Resource]
      def update(id, params)
        request.put("#{ENDPOINT}#{id}/", params)
      end

      # Delete a business card.
      #
      # @param id [Integer]
      # @return [Veryfi::Resource]
      def delete(id)
        request.delete("#{ENDPOINT}#{id}/")
      end
    end
  end
end
