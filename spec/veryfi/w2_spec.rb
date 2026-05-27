# frozen_string_literal: true

require "spec_helper"

RSpec.describe "W2 API" do
  include_context :with_veryfi_client

  let(:w2s_fixture) { response_fixture_body("w2s/list") }
  let(:w2s) { JSON.parse(w2s_fixture)["documents"] }
  let(:document_id) { 77_005_001 }
  let(:base_url) { "https://api.veryfi.com/api/v8/partner/w2s" }

  describe "w2.all" do
    before do
      stub_request(:get, "#{base_url}/").to_return(body: w2s_fixture)
    end

    it "fetches the list" do
      response = client.w2.all

      expect(response["documents"][0]["id"]).to eq(document_id)
    end
  end

  describe "w2.get(id)" do
    before do
      stub_request(:get, "#{base_url}/#{document_id}/").to_return(body: w2s[0].to_json)
    end

    it "fetches a W-2 by id" do
      response = client.w2.get(document_id)

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "w2.process(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: w2s[0].to_json)
    end

    it "uploads a file and POSTs to /w2s/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/w2s/",
        file_name: "receipt.jpg",
        file_data: receipt_file_data
      ).and_call_original

      response = client.w2.process(file_path: file_fixture_path("receipt.jpg"))

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "w2.process_url(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: w2s[0].to_json)
    end

    it "defaults file_name from file_url" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/w2s/",
        file_url: "https://cdn.example.com/w2.pdf",
        file_name: "w2.pdf"
      ).and_call_original

      response = client.w2.process_url(file_url: "https://cdn.example.com/w2.pdf")

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "w2.update(id, params)" do
    before do
      stub_request(:put, "#{base_url}/#{document_id}/").to_return(
        body: w2s[0].merge(notes: "edited").to_json
      )
    end

    it "updates a W-2" do
      response = client.w2.update(document_id, notes: "edited")

      expect(response["notes"]).to eq("edited")
    end
  end

  describe "w2.delete(id)" do
    before do
      stub_request(:delete, "#{base_url}/#{document_id}/").to_return(
        body: { status: "ok", message: "W-2 has been deleted" }.to_json
      )
    end

    it "deletes a W-2" do
      response = client.w2.delete(document_id)

      expect(response["message"]).to eq("W-2 has been deleted")
    end
  end

  it_behaves_like "a resource with tag operations" do
    let(:subject_namespace) { :w2 }
    let(:resource_id) { 77_005_001 }
    let(:tags_endpoint) { "https://api.veryfi.com/api/v8/partner/w2s/#{resource_id}/tags" }
  end
end
