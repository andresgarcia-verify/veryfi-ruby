# frozen_string_literal: true

require "spec_helper"

RSpec.describe "BankStatement API" do
  include_context :with_veryfi_client

  let(:bank_statements_fixture) { response_fixture_body("bank_statements/list") }
  let(:bank_statements) { JSON.parse(bank_statements_fixture)["documents"] }
  let(:document_id) { 88_001_001 }
  let(:base_url) { "https://api.veryfi.com/api/v8/partner/bank-statements" }

  describe "bank_statement.all" do
    before do
      stub_request(:get, "#{base_url}/").to_return(body: bank_statements_fixture)
    end

    it "fetches the list" do
      response = client.bank_statement.all

      expect(response["documents"][0]["id"]).to eq(document_id)
    end
  end

  describe "bank_statement.get(id)" do
    before do
      stub_request(:get, "#{base_url}/#{document_id}/").to_return(body: bank_statements[0].to_json)
    end

    it "fetches a bank statement by id" do
      response = client.bank_statement.get(document_id)

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "bank_statement.process(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: bank_statements[0].to_json)
    end

    let(:process_params) do
      {
        file_path: file_fixture_path("receipt.jpg"),
        categories: %w[Transfer Payroll]
      }
    end

    it "uploads a file and POSTs to /bank-statements/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/bank-statements/",
        file_name: "receipt.jpg",
        file_data: receipt_file_data,
        categories: %w[Transfer Payroll]
      ).and_call_original

      response = client.bank_statement.process(process_params)

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "bank_statement.process_url(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: bank_statements[0].to_json)
    end

    let(:process_params) do
      {
        file_url: "https://cdn.example.com/statement.pdf",
        categories: %w[Transfer Payroll]
      }
    end

    it "defaults file_name from file_url when missing and POSTs to /bank-statements/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/bank-statements/",
        file_url: "https://cdn.example.com/statement.pdf",
        categories: %w[Transfer Payroll],
        file_name: "statement.pdf"
      ).and_call_original

      response = client.bank_statement.process_url(process_params)

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "bank_statement.update(id, params)" do
    before do
      stub_request(:put, "#{base_url}/#{document_id}/").to_return(
        body: bank_statements[0].merge(notes: "edited").to_json
      )
    end

    it "updates a bank statement" do
      response = client.bank_statement.update(document_id, notes: "edited")

      expect(response["notes"]).to eq("edited")
    end
  end

  describe "bank_statement.delete(id)" do
    before do
      stub_request(:delete, "#{base_url}/#{document_id}/").to_return(
        body: { status: "ok", message: "Bank statement has been deleted" }.to_json
      )
    end

    it "deletes a bank statement" do
      response = client.bank_statement.delete(document_id)

      expect(response["message"]).to eq("Bank statement has been deleted")
    end
  end

  describe "bank_statement.process_async(params)" do
    before do
      stub_request(:post, "https://api.veryfi.com/api/v8/partner/bank-statements/async").to_return(
        body: { id: document_id, status: "processing" }.to_json
      )
    end

    it "POSTs uploaded file to /bank-statements/async" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/bank-statements/async",
        file_name: "receipt.jpg",
        file_data: receipt_file_data
      ).and_call_original

      response = client.bank_statement.process_async(file_path: file_fixture_path("receipt.jpg"))

      expect(response["status"]).to eq("processing")
    end
  end

  describe "bank_statement.process_url_async(params)" do
    before do
      stub_request(:post, "https://api.veryfi.com/api/v8/partner/bank-statements/async").to_return(
        body: { id: document_id, status: "processing" }.to_json
      )
    end

    it "POSTs file_url to /bank-statements/async" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/bank-statements/async",
        file_url: "https://cdn.example.com/statement.pdf",
        file_name: "statement.pdf"
      ).and_call_original

      response = client.bank_statement.process_url_async(file_url: "https://cdn.example.com/statement.pdf")

      expect(response["status"]).to eq("processing")
    end
  end

  it_behaves_like "a resource with tag operations" do
    let(:subject_namespace) { :bank_statement }
    let(:resource_id) { 88_001_001 }
    let(:tags_endpoint) { "https://api.veryfi.com/api/v8/partner/bank-statements/#{resource_id}/tags" }
  end
end
