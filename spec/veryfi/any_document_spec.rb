# frozen_string_literal: true

require "spec_helper"

RSpec.describe "AnyDocument API" do
  include_context :with_veryfi_client

  let(:any_documents_fixture) { response_fixture_body("any_documents/list") }
  let(:any_documents) { JSON.parse(any_documents_fixture)["documents"] }
  let(:document_id) { 71_012_001 }
  let(:base_url) { "https://api.veryfi.com/api/v8/partner/any-documents" }

  describe "any_document.all" do
    before do
      stub_request(:get, "#{base_url}/").to_return(body: any_documents_fixture)
    end

    it "fetches the list" do
      response = client.any_document.all

      expect(response["documents"][0]["id"]).to eq(document_id)
    end
  end

  describe "any_document.get(id)" do
    before do
      stub_request(:get, "#{base_url}/#{document_id}/").to_return(body: any_documents[0].to_json)
    end

    it "fetches an a-doc by id" do
      response = client.any_document.get(document_id)

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "any_document.process(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: any_documents[0].to_json)
    end

    let(:process_params) do
      {
        blueprint_name: "us_w2_2022",
        file_path: file_fixture_path("receipt.jpg")
      }
    end

    it "uploads a file and POSTs to /any-documents/ with blueprint_name" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/any-documents/",
        file_name: "receipt.jpg",
        file_data: receipt_file_data,
        blueprint_name: "us_w2_2022"
      ).and_call_original

      response = client.any_document.process(process_params)

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "any_document.process_url(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: any_documents[0].to_json)
    end

    let(:url_params) do
      { blueprint_name: "us_w2_2022", file_url: "https://cdn.example.com/doc.pdf" }
    end

    it "defaults file_name from file_url and forwards blueprint_name" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/any-documents/",
        url_params.merge(file_name: "doc.pdf")
      ).and_call_original

      response = client.any_document.process_url(url_params)

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "any_document.update(id, params)" do
    before do
      stub_request(:put, "#{base_url}/#{document_id}/").to_return(
        body: any_documents[0].merge(notes: "edited").to_json
      )
    end

    it "updates an a-doc" do
      response = client.any_document.update(document_id, notes: "edited")

      expect(response["notes"]).to eq("edited")
    end
  end

  describe "any_document.delete(id)" do
    before do
      stub_request(:delete, "#{base_url}/#{document_id}/").to_return(
        body: { status: "ok", message: "Any document has been deleted" }.to_json
      )
    end

    it "deletes an a-doc" do
      response = client.any_document.delete(document_id)

      expect(response["message"]).to eq("Any document has been deleted")
    end
  end

  describe "any_document.process_async(params)" do
    before do
      stub_request(:post, "https://api.veryfi.com/api/v8/partner/any-documents/async").to_return(
        body: { id: document_id, status: "processing" }.to_json
      )
    end

    let(:expected_payload) do
      {
        file_name: "receipt.jpg", file_data: receipt_file_data, blueprint_name: "us_w2_2022"
      }
    end

    it "POSTs uploaded file to /any-documents/async with blueprint_name" do
      expect_any_instance_of(Veryfi::Request).to receive(:post)
        .with("/partner/any-documents/async", expected_payload).and_call_original

      response = client.any_document.process_async(
        blueprint_name: "us_w2_2022",         file_path: file_fixture_path("receipt.jpg")
      )

      expect(response["status"]).to eq("processing")
    end
  end

  describe "any_document.process_url_async(params)" do
    before do
      stub_request(:post, "https://api.veryfi.com/api/v8/partner/any-documents/async").to_return(
        body: { id: document_id, status: "processing" }.to_json
      )
    end

    let(:url_params) do
      { blueprint_name: "us_w2_2022", file_url: "https://cdn.example.com/doc.pdf" }
    end

    it "POSTs file_url to /any-documents/async" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/any-documents/async",
        url_params.merge(file_name: "doc.pdf")
      ).and_call_original

      response = client.any_document.process_url_async(url_params)

      expect(response["status"]).to eq("processing")
    end
  end

  it_behaves_like "a resource with tag operations" do
    let(:subject_namespace) { :any_document }
    let(:resource_id) { 71_012_001 }
    let(:tags_endpoint) { "https://api.veryfi.com/api/v8/partner/any-documents/#{resource_id}/tags" }
  end
end
