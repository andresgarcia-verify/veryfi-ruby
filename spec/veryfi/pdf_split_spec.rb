# frozen_string_literal: true

require "spec_helper"

RSpec.describe "PdfSplit API" do
  include_context :with_veryfi_client

  let(:documents_set_fixture) { response_fixture_body("documents_set/list") }
  let(:documents_set) { JSON.parse(documents_set_fixture)["documents"] }
  let(:document_id) { 66_004_001 }
  let(:base_url) { "https://api.veryfi.com/api/v8/partner/documents-set" }

  describe "pdf_split.all" do
    before do
      stub_request(:get, "#{base_url}/").to_return(body: documents_set_fixture)
    end

    it "fetches the list" do
      response = client.pdf_split.all

      expect(response["documents"][0]["id"]).to eq(document_id)
    end
  end

  describe "pdf_split.get(id)" do
    before do
      stub_request(:get, "#{base_url}/#{document_id}").to_return(body: documents_set[0].to_json)
    end

    it "fetches the documents extracted from a PDF" do
      response = client.pdf_split.get(document_id)

      expect(response["id"]).to eq(document_id)
      expect(response["documents"].length).to eq(2)
    end
  end

  describe "pdf_split.process(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: documents_set[0].to_json)
    end

    it "uploads a file and POSTs to /documents-set/ (defaulting categories to [])" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/documents-set/",
        file_name: "receipt.jpg",
        file_data: receipt_file_data,
        categories: []
      ).and_call_original

      response = client.pdf_split.process(file_path: file_fixture_path("receipt.jpg"))

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "pdf_split.process_url(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: documents_set[0].to_json)
    end

    it "POSTs file_url to /documents-set/ (defaulting categories to [])" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/documents-set/",
        file_url: "https://cdn.example.com/multi.pdf",
        categories: []
      ).and_call_original

      response = client.pdf_split.process_url(file_url: "https://cdn.example.com/multi.pdf")

      expect(response["id"]).to eq(document_id)
    end
  end
end
