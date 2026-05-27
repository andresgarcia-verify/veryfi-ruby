# frozen_string_literal: true

require "spec_helper"

RSpec.describe "BankStatementSplit API" do
  include_context :with_veryfi_client

  let(:set_fixture) { response_fixture_body("bank_statements_set/list") }
  let(:set_documents) { JSON.parse(set_fixture)["documents"] }
  let(:document_id) { 89_010_001 }
  let(:base_url) { "https://api.veryfi.com/api/v8/partner/bank-statements-set" }

  describe "bank_statement_split.all" do
    before do
      stub_request(:get, "#{base_url}/").to_return(body: set_fixture)
    end

    it "fetches the list" do
      response = client.bank_statement_split.all

      expect(response["documents"][0]["id"]).to eq(document_id)
    end
  end

  describe "bank_statement_split.get(id)" do
    before do
      stub_request(:get, "#{base_url}/#{document_id}").to_return(body: set_documents[0].to_json)
    end

    it "fetches a bank-statements-set by id" do
      response = client.bank_statement_split.get(document_id)

      expect(response["id"]).to eq(document_id)
      expect(response["documents"].length).to eq(2)
    end
  end

  describe "bank_statement_split.process(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: set_documents[0].to_json)
    end

    it "uploads a file and POSTs to /bank-statements-set/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/bank-statements-set/",
        file_name: "receipt.jpg",
        file_data: receipt_file_data
      ).and_call_original

      response = client.bank_statement_split.process(file_path: file_fixture_path("receipt.jpg"))

      expect(response["id"]).to eq(document_id)
    end
  end

  describe "bank_statement_split.process_url(params)" do
    before do
      stub_request(:post, "#{base_url}/").to_return(body: set_documents[0].to_json)
    end

    it "POSTs file_urls to /bank-statements-set/" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/bank-statements-set/",
        file_urls: %w[https://cdn.example.com/a.pdf https://cdn.example.com/b.pdf]
      ).and_call_original

      response = client.bank_statement_split.process_url(
        file_urls: %w[https://cdn.example.com/a.pdf https://cdn.example.com/b.pdf]
      )

      expect(response["id"]).to eq(document_id)
    end
  end
end
