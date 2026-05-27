# frozen_string_literal: true

module Veryfi
  module Api
    # Document classification endpoint (`/partner/classify/`).
    #
    # Given a file and an optional set of candidate document types,
    # returns Veryfi's best guess at what kind of document it is (invoice,
    # receipt, w-2, …) along with confidence scores.
    #
    # @see https://docs.veryfi.com/api/classify/classify-a-document/
    class Classify
      include FilePayload

      ENDPOINT = "/partner/classify/"

      attr_reader :request

      def initialize(request)
        @request = request
      end

      # Upload a local file for classification.
      #
      # @param raw_params [Hash]
      # @option raw_params [String]        :file_path      **required.** Local path.
      # @option raw_params [String]        :file_name      (basename of `:file_path`)
      # @option raw_params [Array<String>] :document_types (`nil` = use Veryfi's full default set)
      #   Restrict the classifier to these document types.
      # @return [Veryfi::Resource] e.g. `{ "document_type" => "invoice", "score" => 0.98, ... }`
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
      # @option raw_params [String]        :file_url       single URL
      # @option raw_params [Array<String>] :file_urls      list of URLs (alternative)
      # @option raw_params [Array<String>] :document_types (`nil`)
      # @return [Veryfi::Resource]
      def process_url(raw_params)
        request.post(ENDPOINT, raw_params.transform_keys(&:to_sym))
      end
    end
  end
end
