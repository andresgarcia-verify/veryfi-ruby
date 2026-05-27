# frozen_string_literal: true

require "spec_helper"

RSpec.describe "TaxLine API" do
  include_context :with_veryfi_client

  let(:tax_lines_fixture) { response_fixture_body("documents/tax_lines") }
  let(:tax_lines) { JSON.parse(tax_lines_fixture)["tax_lines"] }
  let(:document_id) { 44_691_518 }
  let(:base_url) { "https://api.veryfi.com/api/v8/partner/documents/#{document_id}/tax-lines" }

  describe "tax_line.all(document_id)" do
    before do
      stub_request(:get, base_url).to_return(body: tax_lines_fixture)
    end

    it "fetches tax lines for a document" do
      response = client.tax_line.all(document_id)

      expect(response["tax_lines"][0]["id"]).to eq(12_009_001)
    end
  end

  describe "tax_line.create(document_id, params)" do
    before do
      stub_request(:post, base_url).to_return(body: tax_lines[0].to_json)
    end

    let(:tax_line_params) do
      { name: "Sales Tax", rate: 6.25, base: 145.0, total: 9.06, order: 0 }
    end

    it "creates a tax line" do
      response = client.tax_line.create(document_id, tax_line_params)

      expect(response["id"]).to eq(12_009_001)
    end
  end

  describe "tax_line.get(document_id, id)" do
    before do
      stub_request(:get, "#{base_url}/12009001").to_return(body: tax_lines[0].to_json)
    end

    it "fetches a tax line by id" do
      response = client.tax_line.get(document_id, 12_009_001)

      expect(response["id"]).to eq(12_009_001)
    end
  end

  describe "tax_line.update(document_id, id, params)" do
    before do
      stub_request(:put, "#{base_url}/12009001").to_return(
        body: tax_lines[0].merge(rate: 7.0).to_json
      )
    end

    it "updates a tax line" do
      response = client.tax_line.update(document_id, 12_009_001, rate: 7.0)

      expect(response["rate"]).to eq(7.0)
    end
  end

  describe "tax_line.delete(document_id, id)" do
    before do
      stub_request(:delete, "#{base_url}/12009001").to_return(
        body: { status: "ok", message: "Tax line has been deleted" }.to_json
      )
    end

    it "deletes a tax line" do
      response = client.tax_line.delete(document_id, 12_009_001)

      expect(response["message"]).to eq("Tax line has been deleted")
    end
  end
end
