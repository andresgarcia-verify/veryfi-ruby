# frozen_string_literal: true

module Veryfi
  module Api
    # Global tag catalog (`/partner/tags/`).
    #
    # Note: This endpoint is not present in every Veryfi API version. For
    # managing tags on a specific document use {Veryfi::Api::DocumentTag}
    # (or the `.tags` / `.add_tag` / `.add_tags` / `.delete_tag` methods
    # on each processed-document resource — see {TagOperations}).
    class Tag
      attr_reader :request

      def initialize(request)
        @request = request
      end

      # List every tag known to the account.
      #
      # @param params [Hash] optional query-string parameters
      # @return [Array<Veryfi::Resource>] the `"tags"` array from the response
      def all(params = {})
        response = request.get("/partner/tags/", params)

        response["tags"]
      end

      # Delete a tag by id.
      #
      # @param id [Integer]
      # @return [Veryfi::Resource]
      def delete(id)
        request.delete("/partner/tags/#{id}")
      end
    end
  end
end
