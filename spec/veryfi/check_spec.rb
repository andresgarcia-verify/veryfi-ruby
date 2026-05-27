# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Check API" do
  include_context :with_veryfi_client

  let(:checks_fixture) { response_fixture_body("checks/list") }
  let(:checks) { JSON.parse(checks_fixture)["documents"] }
  let(:document_id) { 55_003_001 }
  let(:base_url) { "https://api.veryfi.com/api/v8/partner/checks" }

  describe "check.all" do
    before do
      stub_request(:get, "#{base_url}/").to_return(body: checks_fixture)
    end

    it "fetches the list" do
      response = client.check.all

      expect(response["documents"][0]["id"]).to eq(document_id)
    end
  end

  describe "check.get(id)" do
    before do
      stub_request(:get, "#{base_url}/#{document_id}/").to_return(body: checks[0].to_json)
    end

    it "fetches a check by id" do
      response = client.check.get(document_id)

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "check.process(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: checks[0].to_json)
    end

    it "uploads a file and POSTs to /checks/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/checks/",
        file_name: "receipt.jpg",
        file_data: receipt_file_data
      ).and_call_original

      response = client.check.process(file_path: file_fixture_path("receipt.jpg"))

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "check.process_url(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: checks[0].to_json)
    end

    it "POSTs the file_url payload" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/checks/",
        file_url: "https://cdn.example.com/check.jpg"
      ).and_call_original

      response = client.check.process_url(file_url: "https://cdn.example.com/check.jpg")

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "check.process_with_remittance(params)" do
    before do
      stub_request(:post, "https://api.veryfi.com/api/v8/partner/check-with-document/").to_return(
        body: response_fixture_body("checks/with_remittance")
      )
    end

    it "uploads a file and POSTs to /check-with-document/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/check-with-document/",
        file_name: "receipt.jpg",
        file_data: receipt_file_data
      ).and_call_original

      response = client.check.process_with_remittance(file_path: file_fixture_path("receipt.jpg"))

      expect(response["id"]).to eq(55_009_001)
      expect(response["check"]["check_number"]).to eq("0010")
    end
  end

  describe "check.process_with_remittance_url(params)" do
    before do
      stub_request(:post, "https://api.veryfi.com/api/v8/partner/check-with-document/").to_return(
        body: response_fixture_body("checks/with_remittance")
      )
    end

    it "POSTs the file_url payload to /check-with-document/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/check-with-document/",
        file_url: "https://cdn.example.com/check.jpg"
      ).and_call_original

      response = client.check.process_with_remittance_url(file_url: "https://cdn.example.com/check.jpg")

      expect(response["id"]).to eq(55_009_001)
    end
  end

  describe "check.update(id, params)" do
    before do
      stub_request(:put, "#{base_url}/#{document_id}/").to_return(
        body: checks[0].merge(notes: "edited").to_json
      )
    end

    it "PUTs the update payload" do
      response = client.check.update(document_id, notes: "edited")

      expect(response["notes"]).to eq("edited")
    end
  end

  describe "check.delete(id)" do
    before do
      stub_request(:delete, "#{base_url}/#{document_id}/").to_return(
        body: { status: "ok", message: "Check has been deleted" }.to_json
      )
    end

    it "deletes a check" do
      response = client.check.delete(document_id)

      expect(response["message"]).to eq("Check has been deleted")
    end
  end

  describe "check.process_async(params)" do
    before do
      stub_request(:post, "https://api.veryfi.com/api/v8/partner/checks/async").to_return(
        body: { id: document_id, status: "processing" }.to_json
      )
    end

    it "POSTs uploaded file to /checks/async" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/checks/async",
        file_name: "receipt.jpg",
        file_data: receipt_file_data
      ).and_call_original

      response = client.check.process_async(file_path: file_fixture_path("receipt.jpg"))

      expect(response["status"]).to eq("processing")
    end
  end

  describe "check.process_url_async(params)" do
    before do
      stub_request(:post, "https://api.veryfi.com/api/v8/partner/checks/async").to_return(
        body: { id: document_id, status: "processing" }.to_json
      )
    end

    it "POSTs file_url to /checks/async" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/checks/async",
        file_url: "https://cdn.example.com/check.jpg"
      ).and_call_original

      response = client.check.process_url_async(file_url: "https://cdn.example.com/check.jpg")

      expect(response["status"]).to eq("processing")
    end
  end

  it_behaves_like "a resource with tag operations" do
    let(:subject_namespace) { :check }
    let(:resource_id) { 55_003_001 }
    let(:tags_endpoint) { "https://api.veryfi.com/api/v8/partner/checks/#{resource_id}/tags" }
  end
end
