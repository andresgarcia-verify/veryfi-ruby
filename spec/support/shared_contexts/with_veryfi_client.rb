# frozen_string_literal: true

shared_context :with_veryfi_client do
  let(:client) do
    Veryfi::Client.new(
      client_id: "fBvJLm1zCJ8Doxf94mMrpbrkDp8nr",
      client_secret: "FDPXbxHTrSKPAVOJGoB0doUWhJmmbcm3ajFTwtclagdlygkp3yuIMJjirFbO1oKGC4nr",
      username: "john_doe",
      api_key: "123456"
    )
  end

  # Path to a JSON response fixture, e.g.
  #   response_fixture("documents/list")  → spec/fixtures/responses/documents/list.json
  def response_fixture(name)
    "spec/fixtures/responses/#{name}.json"
  end

  # Read a JSON response fixture from disk as a String.
  def response_fixture_body(name)
    File.read(response_fixture(name))
  end

  # Absolute path to a binary/raw asset fixture, e.g.
  #   file_fixture_path("receipt.jpg")   → /…/spec/fixtures/files/receipt.jpg
  def file_fixture_path(name)
    File.expand_path("spec/fixtures/files/#{name}", Dir.pwd)
  end

  def receipt_file_data
    File.read(file_fixture_path("receipt_base64.txt")).gsub("\n", "")
  end
end
