# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Classify API" do
  include_context :with_veryfi_client

  let(:classification_fixture) { response_fixture_body("classify/result") }
  let(:base_url) { "https://api.veryfi.com/api/v8/partner/classify/" }
  let(:document_types) { %w[invoice receipt] }

  describe "classify.process(params)" do
    before do
      stub_request(:post, base_url).to_return(body: classification_fixture)
    end

    let(:expected_payload) do
      { file_name: "receipt.jpg", file_data: receipt_file_data, document_types: document_types }
    end

    it "uploads a file and POSTs to /classify/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post)
        .with("/partner/classify/", expected_payload).and_call_original

      response = client.classify.process(
        file_path: file_fixture_path("receipt.jpg"), document_types: document_types
      )

      expect(response["document_type"]).to eq("invoice")
    end
  end

  describe "classify.process_url(params)" do
    before do
      stub_request(:post, base_url).to_return(body: classification_fixture)
    end

    let(:url_payload) do
      { file_url: "https://cdn.example.com/receipt.jpg", document_types: document_types }
    end

    it "POSTs file_url (and optional document_types) to /classify/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post)
        .with("/partner/classify/", url_payload).and_call_original

      response = client.classify.process_url(url_payload)

      expect(response["document_type"]).to eq("invoice")
    end
  end
end
