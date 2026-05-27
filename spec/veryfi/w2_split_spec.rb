# frozen_string_literal: true

require "spec_helper"

RSpec.describe "W2Split API" do
  include_context :with_veryfi_client

  let(:w2s_set_fixture) { response_fixture_body("w2s_set/list") }
  let(:w2s_set) { JSON.parse(w2s_set_fixture)["documents"] }
  let(:document_id) { 78_006_001 }
  let(:base_url) { "https://api.veryfi.com/api/v8/partner/w2s-set" }

  describe "w2_split.all" do
    before do
      stub_request(:get, "#{base_url}/").to_return(body: w2s_set_fixture)
    end

    it "fetches the list" do
      response = client.w2_split.all

      expect(response["documents"][0]["id"]).to eq(document_id)
    end
  end

  describe "w2_split.get(id)" do
    before do
      stub_request(:get, "#{base_url}/#{document_id}/").to_return(body: w2s_set[0].to_json)
    end

    it "fetches the documents extracted from a multi-W2 file" do
      response = client.w2_split.get(document_id)

      expect(response["id"]).to eq(document_id)
      expect(response["documents"].length).to eq(2)
    end
  end

  describe "w2_split.process(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: w2s_set[0].to_json)
    end

    it "uploads a file and POSTs to /w2s-set/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/w2s-set/",
        file_name: "receipt.jpg",
        file_data: receipt_file_data
      ).and_call_original

      response = client.w2_split.process(file_path: file_fixture_path("receipt.jpg"))

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "w2_split.process_url(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: w2s_set[0].to_json)
    end

    it "POSTs file_urls to /w2s-set/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/w2s-set/",
        file_urls: %w[https://cdn.example.com/w2_one.pdf https://cdn.example.com/w2_two.pdf]
      ).and_call_original

      response = client.w2_split.process_url(
        file_urls: %w[https://cdn.example.com/w2_one.pdf https://cdn.example.com/w2_two.pdf]
      )

      expect(response["id"]).to eq(document_id)
    end
  end
end
