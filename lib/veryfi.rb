# frozen_string_literal: true

module Veryfi
  autoload :VERSION, "veryfi/version"
  autoload :Signature, "veryfi/signature"
  autoload :Request, "veryfi/request"
  autoload :Resource, "veryfi/resource"
  autoload :Error, "veryfi/error"
  autoload :Configuration, "veryfi/configuration"

  module Api
    autoload :FilePayload, "veryfi/api/file_payload"
    autoload :TagOperations, "veryfi/api/tag_operations"

    autoload :Document, "veryfi/api/document"
    autoload :LineItem, "veryfi/api/line_item"
    autoload :TaxLine, "veryfi/api/tax_line"
    autoload :Tag, "veryfi/api/tag"
    autoload :DocumentTag, "veryfi/api/document_tag"

    autoload :AnyDocument, "veryfi/api/any_document"
    autoload :BankStatement, "veryfi/api/bank_statement"
    autoload :BankStatementSplit, "veryfi/api/bank_statement_split"
    autoload :BusinessCard, "veryfi/api/business_card"
    autoload :Check, "veryfi/api/check"
    autoload :Classify, "veryfi/api/classify"
    autoload :PdfSplit, "veryfi/api/pdf_split"
    autoload :W2, "veryfi/api/w2"
    autoload :W2Split, "veryfi/api/w2_split"
    autoload :W8, "veryfi/api/w8"
    autoload :W9, "veryfi/api/w9"
  end

  autoload :Client, "veryfi/client"

  class << self
    # Process-wide configuration, used by {Veryfi.client} as defaults when
    # constructing the shared client. You can still call
    # `Veryfi::Client.new(...)` directly to bypass this entirely.
    #
    # @example
    #   Veryfi.configure do |c|
    #     c.client_id     = ENV.fetch("VERYFI_CLIENT_ID")
    #     c.client_secret = ENV.fetch("VERYFI_CLIENT_SECRET")
    #     c.username      = ENV.fetch("VERYFI_USERNAME")
    #     c.api_key       = ENV.fetch("VERYFI_API_KEY")
    #   end
    #
    #   Veryfi.client.document.process(file_path: "./receipt.jpg")
    #
    # @yieldparam config [Veryfi::Configuration]
    # @return [Veryfi::Configuration]
    def configure
      yield(configuration) if block_given?
      configuration
    end

    # @return [Veryfi::Configuration] the global configuration object.
    def configuration
      @_configuration ||= Veryfi::Configuration.new
    end

    # Process-wide memoized {Veryfi::Client} built from {.configuration}.
    # Resets if you re-{.configure} the SDK after first use.
    #
    # @return [Veryfi::Client]
    def client
      @_client = nil if @_last_configuration_hash && @_last_configuration_hash != configuration.to_h
      @_last_configuration_hash = configuration.to_h
      @_client ||= Veryfi::Client.new(**configuration.to_h.compact)
    end

    # Drop the memoized {.client} and {.configuration}. Mostly useful in tests.
    # @return [void]
    def reset!
      @_configuration = nil
      @_client = nil
      @_last_configuration_hash = nil
    end
  end
end
