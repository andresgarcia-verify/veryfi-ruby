# frozen_string_literal: true

require "base64"

module Veryfi
  module Api
    # Mix-in providing a small helper to turn a local file path into the
    # `{ file_name:, file_data: }` payload that all of Veryfi's "process"
    # endpoints expect.
    module FilePayload
      private

      def file_payload(file_path, file_name = nil)
        encoded = Base64.encode64(File.read(file_path)).gsub("\n", "")

        {
          file_name: file_name || File.basename(file_path),
          file_data: encoded
        }
      end
    end
  end
end
