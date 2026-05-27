# frozen_string_literal: true

module Veryfi
  module Api
    # Any Document (a-doc) endpoints (`/partner/any-documents/`).
    #
    # An A-Doc is a custom document type, defined by a *blueprint* you
    # configure in Veryfi. Every "process" call must therefore include a
    # `:blueprint_name`.
    #
    # @see https://docs.veryfi.com/api/anydocs/
    class AnyDocument
      include FilePayload
      include TagOperations

      ENDPOINT = "/partner/any-documents/"
      ASYNC_ENDPOINT = "/partner/any-documents/async"

      attr_reader :request

      def initialize(request)
        @request = request
      end

      # List previously processed A-Docs.
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

      # Fetch a single A-Doc by id.
      #
      # @param id [Integer]
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource]
      def get(id, params = {})
        request.get("#{ENDPOINT}#{id}/", params)
      end

      # Upload a file and extract its fields using the given blueprint.
      #
      # @param raw_params [Hash]
      # @option raw_params [String] :blueprint_name **required.** Blueprint id to apply.
      # @option raw_params [String] :file_path      **required.** Local path to the file.
      # @option raw_params [String] :file_name      (basename of `:file_path`)
      # @return [Veryfi::Resource]
      def process(raw_params)
        params = raw_params.transform_keys(&:to_sym)
        blueprint_name = params.delete(:blueprint_name)
        file_path = params.delete(:file_path)
        file_name = params.delete(:file_name)

        payload = file_payload(file_path, file_name).merge(blueprint_name: blueprint_name).merge(params)

        request.post(ENDPOINT, payload)
      end

      # Process an A-Doc from a public URL.
      #
      # @param raw_params [Hash]
      # @option raw_params [String] :blueprint_name **required.**
      # @option raw_params [String] :file_url       **required** (single URL).
      # @option raw_params [String] :file_name      (basename of `:file_url`)
      # @return [Veryfi::Resource]
      def process_url(raw_params)
        params = raw_params.transform_keys(&:to_sym)
        params[:file_name] ||= File.basename(params[:file_url]) if params[:file_url]

        request.post(ENDPOINT, params)
      end

      # Same as {#process} but asynchronous — returns immediately with a
      # `"status": "processing"` payload while Veryfi runs the extraction
      # in the background. Use a webhook (or poll {#get}) to learn when the
      # final result is ready.
      #
      # @see https://docs.veryfi.com/api/anydocs/process-a-doc-async/
      def process_async(raw_params)
        params = raw_params.transform_keys(&:to_sym)
        blueprint_name = params.delete(:blueprint_name)
        file_path = params.delete(:file_path)
        file_name = params.delete(:file_name)

        payload = file_payload(file_path, file_name).merge(blueprint_name: blueprint_name).merge(params)

        request.post(ASYNC_ENDPOINT, payload)
      end

      # URL variant of {#process_async}.
      def process_url_async(raw_params)
        params = raw_params.transform_keys(&:to_sym)
        params[:file_name] ||= File.basename(params[:file_url]) if params[:file_url]

        request.post(ASYNC_ENDPOINT, params)
      end

      # Update writable fields on a processed A-Doc.
      #
      # @param id [Integer]
      # @param params [Hash] writable fields
      # @return [Veryfi::Resource]
      def update(id, params)
        request.put("#{ENDPOINT}#{id}/", params)
      end

      # Delete an A-Doc.
      #
      # @param id [Integer]
      # @return [Veryfi::Resource]
      def delete(id)
        request.delete("#{ENDPOINT}#{id}/")
      end
    end
  end
end
