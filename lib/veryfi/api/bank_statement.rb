# frozen_string_literal: true

module Veryfi
  module Api
    # Bank Statements endpoints (`/partner/bank-statements/`).
    #
    # @see https://docs.veryfi.com/api/bank-statements/
    class BankStatement
      include FilePayload
      include TagOperations

      ENDPOINT = "/partner/bank-statements/"
      ASYNC_ENDPOINT = "/partner/bank-statements/async"

      attr_reader :request

      def initialize(request)
        @request = request
      end

      # List previously processed bank statements.
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

      # Fetch a single bank statement by id.
      #
      # @param id [Integer]
      # @param params [Hash] optional query-string parameters
      # @return [Veryfi::Resource]
      def get(id, params = {})
        request.get("#{ENDPOINT}#{id}/", params)
      end

      # Upload a file and extract bank-statement data.
      #
      # @param raw_params [Hash]
      # @option raw_params [String]        :file_path  **required.** Local path.
      # @option raw_params [String]        :file_name  (basename of `:file_path`)
      # @option raw_params [Array<String>] :categories (`nil`) Optional categories used to classify
      #   transactions, e.g. `["Transfer", "Credit Card Payments"]`.
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
      # @option raw_params [String]        :file_url   **required.** Publicly accessible URL.
      # @option raw_params [String]        :file_name  (basename of `:file_url`)
      # @option raw_params [Array<String>] :categories (`nil`)
      # @return [Veryfi::Resource]
      def process_url(raw_params)
        params = raw_params.transform_keys(&:to_sym)
        params[:file_name] ||= File.basename(params[:file_url]) if params[:file_url]

        request.post(ENDPOINT, params)
      end

      # Async variant of {#process} — returns immediately while Veryfi
      # extracts the data in the background.
      def process_async(raw_params)
        params = raw_params.transform_keys(&:to_sym)
        file_path = params.delete(:file_path)
        file_name = params.delete(:file_name)

        payload = file_payload(file_path, file_name).merge(params)

        request.post(ASYNC_ENDPOINT, payload)
      end

      # Async variant of {#process_url}.
      def process_url_async(raw_params)
        params = raw_params.transform_keys(&:to_sym)
        params[:file_name] ||= File.basename(params[:file_url]) if params[:file_url]

        request.post(ASYNC_ENDPOINT, params)
      end

      # Update writable fields on a processed bank statement.
      #
      # @param id [Integer]
      # @param params [Hash]
      # @return [Veryfi::Resource]
      def update(id, params)
        request.put("#{ENDPOINT}#{id}/", params)
      end

      # Delete a bank statement.
      #
      # @param id [Integer]
      # @return [Veryfi::Resource]
      def delete(id)
        request.delete("#{ENDPOINT}#{id}/")
      end
    end
  end
end
