# frozen_string_literal: true

require "spec_helper"

# End-to-end verification that EVERY API namespace returns responses
# wrapped in `Veryfi::Resource` and exposes them through both:
#   * Hash-style access:      response["id"], response[:id], response.dig(...)
#   * attribute-style access: response.id
#
# The unit behaviour of `Veryfi::Resource` is already covered in detail by
# `spec/veryfi/resource_spec.rb`. The point of this file is to prove that
# the wrapping actually happens through the real `Request#process_response`
# code path for every resource class, so a future refactor in `Request`
# can't silently regress one endpoint while leaving the others working.

module ResourceWrappingFixtures
  FIRST_DOC = ->(body) { JSON.parse(body)["documents"].first.to_json }

  # rubocop:disable Layout/LineLength, Layout/ExtraSpacing
  CASES = [
    { resource: :document,             method: :get,         args: [44_691_518],                     verb: :get,  path: "/partner/documents/44691518",            fixture: "documents/list",            response_transformer: FIRST_DOC, attribute: :id, expected: 44_691_518 },
    { resource: :line_item,            method: :all,         args: [12_345],                         verb: :get,  path: "/partner/documents/12345/line-items/",   fixture: "documents/line_items",                                       attribute: :id, expected: 101_170_751, returns: :array },
    { resource: :tax_line,             method: :all,         args: [12_345],                         verb: :get,  path: "/partner/documents/12345/tax-lines",     fixture: "documents/tax_lines",                                        attribute: :tax_lines, expected: :array },
    { resource: :tag,                  method: :all,         args: [],                               verb: :get,  path: "/partner/tags/",                         fixture: "tags/list",                                                  attribute: :id, expected: 75_788_890, returns: :array },
    { resource: :any_document,         method: :get,         args: [71_012_001],                     verb: :get,  path: "/partner/any-documents/71012001/",       fixture: "any_documents/list",        response_transformer: FIRST_DOC, attribute: :id, expected: 71_012_001 },
    { resource: :bank_statement,       method: :get,         args: [88_001_001],                     verb: :get,  path: "/partner/bank-statements/88001001/",     fixture: "bank_statements/list",      response_transformer: FIRST_DOC, attribute: :id, expected: 88_001_001 },
    { resource: :bank_statement_split, method: :get,         args: [89_010_001],                     verb: :get,  path: "/partner/bank-statements-set/89010001",  fixture: "bank_statements_set/list", response_transformer: FIRST_DOC, attribute: :id, expected: 89_010_001 },
    { resource: :business_card,        method: :get,         args: [99_002_001],                     verb: :get,  path: "/partner/business-cards/99002001/",      fixture: "business_cards/list",       response_transformer: FIRST_DOC, attribute: :id, expected: 99_002_001 },
    { resource: :check,                method: :get,         args: [55_003_001],                     verb: :get,  path: "/partner/checks/55003001/",              fixture: "checks/list",               response_transformer: FIRST_DOC, attribute: :id, expected: 55_003_001 },
    { resource: :pdf_split,            method: :get,         args: [66_004_001],                     verb: :get,  path: "/partner/documents-set/66004001",        fixture: "documents_set/list",        response_transformer: FIRST_DOC, attribute: :id, expected: 66_004_001 },
    { resource: :w2,                   method: :get,         args: [77_005_001],                     verb: :get,  path: "/partner/w2s/77005001/",                 fixture: "w2s/list",                  response_transformer: FIRST_DOC, attribute: :id, expected: 77_005_001 },
    { resource: :w2_split,             method: :get,         args: [78_006_001],                     verb: :get,  path: "/partner/w2s-set/78006001/",             fixture: "w2s_set/list",              response_transformer: FIRST_DOC, attribute: :id, expected: 78_006_001 },
    { resource: :w8,                   method: :get,         args: [79_007_001],                     verb: :get,  path: "/partner/w-8ben-e/79007001/",            fixture: "w8s/list",                  response_transformer: FIRST_DOC, attribute: :id, expected: 79_007_001 },
    { resource: :w9,                   method: :get,         args: [80_008_001],                     verb: :get,  path: "/partner/w9s/80008001/",                 fixture: "w9s/list",                  response_transformer: FIRST_DOC, attribute: :id, expected: 80_008_001 },
    { resource: :classify,             method: :process_url, args: [{ file_url: "https://x/x.jpg" }], verb: :post, path: "/partner/classify/",                     fixture: "classify/result",                                            attribute: :document_type, expected: "invoice" }
  ].freeze
  # rubocop:enable Layout/LineLength, Layout/ExtraSpacing
end

RSpec.describe "Resource wrapping (end-to-end through Request)" do
  include_context :with_veryfi_client

  ResourceWrappingFixtures::CASES.each do |c|
    describe "client.#{c[:resource]}.#{c[:method]}" do
      let(:body) do
        raw = response_fixture_body(c[:fixture])
        c[:response_transformer] ? c[:response_transformer].call(raw) : raw
      end

      let(:response) do
        stub_request(c[:verb], "https://api.veryfi.com/api/v8#{c[:path]}").to_return(body: body)
        client.public_send(c[:resource]).public_send(c[:method], *c[:args])
      end

      it "returns a Hash-compatible Veryfi::Resource (or Array thereof)" do
        if c[:returns] == :array
          expect(response).to be_an(Array)
          expect(response.first).to be_a(Veryfi::Resource)
          expect(response.first).to be_a(Hash)
        else
          expect(response).to be_a(Veryfi::Resource)
          expect(response).to be_a(Hash)
        end
      end

      it "returns the same value via [\"#{c[:attribute]}\"], [:#{c[:attribute]}] and .#{c[:attribute]}" do
        target = c[:returns] == :array ? response.first : response

        bracket_str = target[c[:attribute].to_s]
        bracket_sym = target[c[:attribute].to_sym]
        method_call = target.public_send(c[:attribute])

        expect(bracket_str).to eq(bracket_sym)
        expect(bracket_str).to eq(method_call)
        expect(bracket_str).to eq(c[:expected]) unless c[:expected] == :array
      end
    end
  end

  describe "deeply nested attribute access (recursive wrapping)" do
    let(:response) do
      stub_request(:get, "https://api.veryfi.com/api/v8/partner/documents/44691518").to_return(
        body: JSON.parse(response_fixture_body("documents/list"))["documents"].first.to_json
      )
      client.document.get(44_691_518)
    end

    it "wraps nested hashes" do
      expect(response.bill_to).to be_a(Veryfi::Resource)
      expect(response.bill_to.name).to eq(response["bill_to"]["name"])
    end

    it "wraps arrays of hashes into arrays of Resources" do
      expect(response.line_items).to all(be_a(Veryfi::Resource))
      expect(response.line_items.first.description).to eq(response["line_items"][0]["description"])
    end
  end
end
