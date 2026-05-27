# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Document Tag API" do
  include_context :with_veryfi_client

  let(:tags_fixture) { response_fixture_body("tags/list") }
  let(:tags) { JSON.parse(tags_fixture)["tags"] }

  let(:document_id) { 38_947_300 }
  let(:base_url) { "https://api.veryfi.com/api/v8/partner/documents/#{document_id}" }

  describe "document_tag.all(document_id)" do
    before do
      stub_request(:get, "#{base_url}/tags/").to_return(
        body: tags_fixture
      )
    end

    it "can fetch document tags" do
      response = client.document_tag.all(document_id)

      expect(response[0]["name"]).to eq("foo")
    end
  end

  describe "document_tag.add(document_id, params)" do
    before do
      stub_request(:put, "#{base_url}/tags/").to_return(body: tags[0].to_json)
    end

    let(:tag_params) { { name: "foo" } }

    it "can create tag for a given document" do
      response = client.document_tag.add(document_id, tag_params)

      expect(response["name"]).to eq("foo")
    end
  end

  describe "document_tag.delete(document_id, id)" do
    before do
      stub_request(:delete, "#{base_url}/tags/75788890").to_return(
        body: { status: "ok", message: "Tag has been removed from document" }.to_json
      )
    end

    it "can delete tag from document by tag id" do
      response = client.document_tag.delete(document_id, 75_788_890)

      expect(response["message"]).to eq("Tag has been removed from document")
    end
  end

  describe "document_tag.delete_all(document_id)" do
    before do
      stub_request(:delete, "#{base_url}/tags/").to_return(
        body: { status: "ok", message: "Tag has been removed from document" }.to_json
      )
    end

    it "can delete all tag from given document" do
      response = client.document_tag.delete_all(document_id)

      expect(response["message"]).to eq("Tag has been removed from document")
    end
  end

  describe "document_tag.add_multiple(document_id, tags)" do
    before do
      stub_request(:post, "#{base_url}/tags/").to_return(body: tags_fixture)
    end

    it "can add multiple tags to a document in one call" do
      expect_any_instance_of(Veryfi::Request).to receive(:post).with(
        "/partner/documents/#{document_id}/tags/",
        tags: %w[foo bar baz]
      ).and_call_original

      response = client.document_tag.add_multiple(document_id, %w[foo bar baz])

      expect(response["tags"].length).to eq(3)
    end
  end

  describe "document_tag.replace(document_id, tags)" do
    before do
      stub_request(:put, "https://api.veryfi.com/api/v8/partner/documents/#{document_id}/").to_return(
        body: { id: document_id, tags: tags }.to_json
      )
    end

    it "replaces the tags collection on the document" do
      expect_any_instance_of(Veryfi::Request).to receive(:put).with(
        "/partner/documents/#{document_id}/",
        tags: %w[foo bar baz]
      ).and_call_original

      response = client.document_tag.replace(document_id, %w[foo bar baz])

      expect(response["tags"].length).to eq(3)
    end
  end
end
