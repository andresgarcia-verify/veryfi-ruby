# frozen_string_literal: true

# Shared examples for resources that include Veryfi::Api::TagOperations.
#
# The host spec must define:
#   - `subject_namespace` — symbol, e.g. :check (so we call client.check.add_tag)
#   - `tags_endpoint`     — full URL prefix up to and including `.../{id}/tags`,
#                            e.g. "https://api.veryfi.com/api/v8/partner/checks/123/tags"
#   - `resource_id`       — id of the parent resource (integer)
shared_examples "a resource with tag operations" do
  let(:tags_fixture) { response_fixture_body("tags/list") }
  let(:tag) { JSON.parse(tags_fixture)["tags"][0] }

  describe ".tags(id)" do
    before { stub_request(:get, tags_endpoint).to_return(body: tags_fixture) }

    it "fetches tags for the resource" do
      response = client.public_send(subject_namespace).tags(resource_id)

      expect(response["tags"][0]["name"]).to eq("foo")
    end
  end

  describe ".add_tag(id, params)" do
    before { stub_request(:put, tags_endpoint).to_return(body: tag.to_json) }

    it "adds a single tag (PUT)" do
      response = client.public_send(subject_namespace).add_tag(resource_id, name: "foo")

      expect(response["name"]).to eq("foo")
    end
  end

  describe ".add_tags(id, tags)" do
    before { stub_request(:post, tags_endpoint).to_return(body: tags_fixture) }

    it "adds multiple tags in one call (POST)" do
      expect_any_instance_of(Veryfi::Request).to receive(:post)
        .with(anything, tags: %w[foo bar baz]).and_call_original

      response = client.public_send(subject_namespace).add_tags(resource_id, %w[foo bar baz])

      expect(response["tags"].length).to eq(3)
    end
  end

  describe ".delete_tag(id, tag_id)" do
    before do
      stub_request(:delete, "#{tags_endpoint}/75788890").to_return(
        body: { status: "ok", message: "Tag has been removed" }.to_json
      )
    end

    it "deletes a single tag" do
      response = client.public_send(subject_namespace).delete_tag(resource_id, 75_788_890)

      expect(response["message"]).to eq("Tag has been removed")
    end
  end

  describe ".delete_tags(id)" do
    before do
      stub_request(:delete, tags_endpoint).to_return(
        body: { status: "ok", message: "All tags removed" }.to_json
      )
    end

    it "deletes all tags for the resource" do
      response = client.public_send(subject_namespace).delete_tags(resource_id)

      expect(response["message"]).to eq("All tags removed")
    end
  end
end
