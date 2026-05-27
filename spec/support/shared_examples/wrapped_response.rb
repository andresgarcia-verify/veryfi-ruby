# frozen_string_literal: true

# Shared example used by every resource spec to demonstrate that the
# response coming out of a real `Veryfi::Request` round-trip is a
# `Veryfi::Resource` and supports BOTH access styles equivalently.
#
# Usage:
#
#   it_behaves_like "a Veryfi::Resource response" do
#     let(:resource_call)        { -> { client.document.get(document_id) } }
#     let(:attribute_under_test) { :id }
#     let(:expected_value)       { 44_691_518 }
#   end
RSpec.shared_examples "a Veryfi::Resource response" do
  let(:wrapped_response) { resource_call.call }

  it "is a Veryfi::Resource (Hash-compatible subclass)" do
    expect(wrapped_response).to be_a(Veryfi::Resource)
    expect(wrapped_response).to be_a(Hash)
  end

  it "returns the same value via response[\"#{attribute_under_test}\"] and via response.#{attribute_under_test}" do
    bracket = wrapped_response[attribute_under_test.to_s]
    symbol  = wrapped_response[attribute_under_test.to_sym]
    method  = wrapped_response.public_send(attribute_under_test)

    expect(bracket).to eq(expected_value)
    expect(symbol).to  eq(expected_value)
    expect(method).to  eq(expected_value)
  end
end
