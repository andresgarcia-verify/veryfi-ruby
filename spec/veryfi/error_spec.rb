# frozen_string_literal: true

require "spec_helper"

RSpec.describe Veryfi::Error do
  describe ".from_response" do
    {
      400 => Veryfi::Error::BadRequest,
      401 => Veryfi::Error::Unauthorized,
      403 => Veryfi::Error::AccessLimitReached,
      404 => Veryfi::Error::NotFound,
      408 => Veryfi::Error::RequestTimeout,
      409 => Veryfi::Error::Conflict,
      415 => Veryfi::Error::UnsupportedMediaType,
      429 => Veryfi::Error::TooManyRequests
    }.each do |status, klass|
      it "maps HTTP #{status} → #{klass}" do
        error = described_class.from_response(status, { "error" => "boom" })

        expect(error).to be_a(klass)
        expect(error).to be_a(Veryfi::Error::VeryfiError)
        expect(error.status).to eq(status)
      end
    end

    it "maps other 4xx statuses to ClientError" do
      error = described_class.from_response(418, { "error" => "I'm a teapot" })

      expect(error).to be_a(Veryfi::Error::ClientError)
      expect(error).to be_a(Veryfi::Error::VeryfiError)
    end

    it "maps 5xx statuses to ServerError" do
      error = described_class.from_response(503, { "error" => "unavailable" })

      expect(error).to be_a(Veryfi::Error::ServerError)
      expect(error).to be_a(Veryfi::Error::VeryfiError)
    end

    it "exposes the parsed response and status" do
      response = { "error" => "boom", "code" => 400 }
      error = described_class.from_response(400, response)

      expect(error.response).to eq(response)
      expect(error.status).to eq(400)
    end

    it "pretty-prints the response in #message and #to_s" do
      error = described_class.from_response(400, { "code" => 400, "error" => "Bad" })

      expected = <<~TEXT.chomp
        {
          "code": 400,
          "error": "Bad"
        }
      TEXT
      expect(error.message).to eq(expected)
      expect(error.to_s).to eq(expected)
    end

    it "propagates the message to StandardError#message (super) — regression for super(message) bug" do
      error = described_class.from_response(400, { "error" => "oops" })

      expect(StandardError.instance_method(:message).bind(error).call).to eq(error.message)
    end

    it "falls back to status string when response is empty" do
      error = described_class.from_response(501, {})

      expect(error).to be_a(Veryfi::Error::ServerError)
      expect(error.message).to eq("501")
      expect(error.response).to eq({})
    end

    it "falls back to the base VeryfiError for non-4xx/5xx statuses" do
      error = described_class.from_response(302, { "error" => "redirected" })

      expect(error.class).to eq(Veryfi::Error::VeryfiError)
      expect(error.status).to eq(302)
    end
  end
end
