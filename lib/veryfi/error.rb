# frozen_string_literal: true

require "json"

module Veryfi
  # Namespace + factory for every error raised by this SDK.
  #
  # All errors inherit from {VeryfiError}, so callers that only need to
  # know "something went wrong with Veryfi" can keep using:
  #
  #   begin
  #     client.document.process(file_path: path)
  #   rescue Veryfi::Error::VeryfiError => e
  #     # …
  #   end
  #
  # Callers that want to react differently per HTTP status can rescue a
  # more specific subclass:
  #
  #   begin
  #     client.document.process(file_path: path)
  #   rescue Veryfi::Error::Unauthorized       then refresh_credentials!
  #   rescue Veryfi::Error::TooManyRequests    then back_off
  #   rescue Veryfi::Error::ServerError        then schedule_retry
  #   rescue Veryfi::Error::VeryfiError        then log_and_raise
  #   end
  class Error
    # Base class for every Veryfi SDK error.
    #
    # `#message` returns the pretty-printed JSON error payload when one is
    # available, otherwise the formatted `"<status>"` / `"<status>, <error>"`
    # string. The `#status` and `#response` accessors give callers
    # programmatic access to the same information.
    class VeryfiError < StandardError
      attr_reader :message, :status, :response

      def initialize(message = "An error occurred", response = {}, status = nil)
        @status = status
        @response = response
        @message = if response.nil? || response.empty?
          message
        else
          JSON.pretty_generate(response)
        end
        super(@message)
      end

      def to_s
        message
      end
    end

    # 400 — request was malformed or failed server-side validation.
    class BadRequest < VeryfiError; end
    # 401 — credentials are missing, invalid, or expired.
    class Unauthorized < VeryfiError; end
    # 403 — credentials are valid but lack permission for this resource.
    class AccessLimitReached < VeryfiError; end
    # 404 — the resource id does not exist (or has been deleted).
    class NotFound < VeryfiError; end
    # 408 — the request timed out before Veryfi could respond.
    class RequestTimeout < VeryfiError; end
    # 409 — request conflicts with current resource state.
    class Conflict < VeryfiError; end
    # 415 — uploaded file type is not supported by the endpoint.
    class UnsupportedMediaType < VeryfiError; end
    # 429 — you've hit a rate limit. Back off and retry.
    class TooManyRequests < VeryfiError; end
    # Catch-all for any other 4xx the server returns.
    class ClientError < VeryfiError; end
    # 5xx — Veryfi reported an internal error. Retrying with backoff is usually safe.
    class ServerError < VeryfiError; end

    STATUS_MAP = {
      400 => BadRequest,
      401 => Unauthorized,
      403 => AccessLimitReached,
      404 => NotFound,
      408 => RequestTimeout,
      409 => Conflict,
      415 => UnsupportedMediaType,
      429 => TooManyRequests
    }.freeze
    private_constant :STATUS_MAP

    # Build the right error subclass for the given HTTP status + response
    # body. Always returns an instance of {VeryfiError} or one of its
    # subclasses; never raises.
    #
    # @param status   [Integer]                       HTTP status code
    # @param response [Hash, Veryfi::Resource, nil]   parsed JSON body
    # @return [VeryfiError]
    def self.from_response(status, response)
      klass = error_class_for(status)
      message = format_message(status, response)

      klass.new(message, response, status)
    end

    def self.error_class_for(status)
      return STATUS_MAP[status] if STATUS_MAP.key?(status)
      return ServerError        if status.between?(500, 599)
      return ClientError        if status.between?(400, 499)

      VeryfiError
    end
    private_class_method :error_class_for

    def self.format_message(status, response)
      if response.nil? || response.empty?
        format("%<code>d", code: status)
      else
        format("%<code>d, %<message>s", code: status, message: response["error"])
      end
    end
    private_class_method :format_message
  end
end
