# frozen_string_literal: true

require "spec_helper"

RSpec.describe "BusinessCard API" do
  include_context :with_veryfi_client

  let(:business_cards_fixture) { response_fixture_body("business_cards/list") }
  let(:business_cards) { JSON.parse(business_cards_fixture)["documents"] }
  let(:document_id) { 99_002_001 }
  let(:base_url) { "https://api.veryfi.com/api/v8/partner/business-cards" }

  describe "business_card.all" do
    before do
      stub_request(:get, "#{base_url}/").to_return(body: business_cards_fixture)
    end

    it "fetches the list" do
      response = client.business_card.all

      expect(response["documents"][0]["id"]).to eq(document_id)
    end
  end

  describe "business_card.get(id)" do
    before do
      stub_request(:get, "#{base_url}/#{document_id}/").to_return(body: business_cards[0].to_json)
    end

    it "fetches a business card by id" do
      response = client.business_card.get(document_id)

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "business_card.process(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: business_cards[0].to_json)
    end

    let(:process_params) do
      {
        file_path: file_fixture_path("receipt.jpg")
      }
    end

    it "uploads a file and POSTs to /business-cards/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/business-cards/",
        file_name: "receipt.jpg",
        file_data: receipt_file_data
      ).and_call_original

      response = client.business_card.process(process_params)

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "business_card.process_url(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: business_cards[0].to_json)
    end

    it "defaults file_name from file_url when missing" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/business-cards/",
        file_url: "https://cdn.example.com/card.jpg",
        file_name: "card.jpg"
      ).and_call_original

      response = client.business_card.process_url(file_url: "https://cdn.example.com/card.jpg")

      expect(response["id"]).to eq(document_id)
    end

    it "respects an explicit file_name" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/business-cards/",
        file_url: "https://cdn.example.com/card.jpg",
        file_name: "custom.jpg"
      ).and_call_original

      response = client.business_card.process_url(
        file_url: "https://cdn.example.com/card.jpg",
        file_name: "custom.jpg"
      )

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "business_card.update(id, params)" do
    before do
      stub_request(:put, "#{base_url}/#{document_id}/").to_return(
        body: business_cards[0].merge(company: "Globex").to_json
      )
    end

    it "updates a business card" do
      response = client.business_card.update(document_id, company: "Globex")

      expect(response["company"]).to eq("Globex")
    end
  end

  describe "business_card.delete(id)" do
    before do
      stub_request(:delete, "#{base_url}/#{document_id}/").to_return(
        body: { status: "ok", message: "Business card has been deleted" }.to_json
      )
    end

    it "deletes a business card" do
      response = client.business_card.delete(document_id)

      expect(response["message"]).to eq("Business card has been deleted")
    end
  end

  it_behaves_like "a resource with tag operations" do
    let(:subject_namespace) { :business_card }
    let(:resource_id) { 99_002_001 }
    let(:tags_endpoint) { "https://api.veryfi.com/api/v8/partner/business-cards/#{resource_id}/tags" }
  end
end
