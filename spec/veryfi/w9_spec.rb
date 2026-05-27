# frozen_string_literal: true

require "spec_helper"

RSpec.describe "W9 API" do
  include_context :with_veryfi_client

  let(:w9s_fixture) { response_fixture_body("w9s/list") }
  let(:w9s) { JSON.parse(w9s_fixture)["documents"] }
  let(:document_id) { 80_008_001 }
  let(:base_url) { "https://api.veryfi.com/api/v8/partner/w9s" }

  describe "w9.all" do
    before do
      stub_request(:get, "#{base_url}/").to_return(body: w9s_fixture)
    end

    it "fetches the list" do
      response = client.w9.all

      expect(response["documents"][0]["id"]).to eq(document_id)
    end
  end

  describe "w9.get(id)" do
    before do
      stub_request(:get, "#{base_url}/#{document_id}/").to_return(body: w9s[0].to_json)
    end

    it "fetches a W-9 by id" do
      response = client.w9.get(document_id)

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "w9.process(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: w9s[0].to_json)
    end

    it "uploads a file and POSTs to /w9s/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/w9s/",
        file_name: "receipt.jpg",
        file_data: receipt_file_data
      ).and_call_original

      response = client.w9.process(file_path: file_fixture_path("receipt.jpg"))

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "w9.process_url(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: w9s[0].to_json)
    end

    it "defaults file_name from file_url" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/w9s/",
        file_url: "https://cdn.example.com/w9.pdf",
        file_name: "w9.pdf"
      ).and_call_original

      response = client.w9.process_url(file_url: "https://cdn.example.com/w9.pdf")

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "w9.update(id, params)" do
    before do
      stub_request(:put, "#{base_url}/#{document_id}/").to_return(
        body: w9s[0].merge(notes: "edited").to_json
      )
    end

    it "updates a W-9" do
      response = client.w9.update(document_id, notes: "edited")

      expect(response["notes"]).to eq("edited")
    end
  end

  describe "w9.delete(id)" do
    before do
      stub_request(:delete, "#{base_url}/#{document_id}/").to_return(
        body: { status: "ok", message: "W-9 has been deleted" }.to_json
      )
    end

    it "deletes a W-9" do
      response = client.w9.delete(document_id)

      expect(response["message"]).to eq("W-9 has been deleted")
    end
  end

  it_behaves_like "a resource with tag operations" do
    let(:subject_namespace) { :w9 }
    let(:resource_id) { 80_008_001 }
    let(:tags_endpoint) { "https://api.veryfi.com/api/v8/partner/w9s/#{resource_id}/tags" }
  end
end
