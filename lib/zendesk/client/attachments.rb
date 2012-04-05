module Zendesk
  class Client
    module Attachments
      # @zendesk.attachments
      def attachments
        AttachmentsCollection.new(self)
      end
    end

    class AttachmentsCollection < Collection
      def initialize(client)
        super(client, :upload)
      end

      def post(data = {})
        super(@query[:path], :filename => data[:filename],
                             :content => File.open(data[:filename]).read,
                             :token => data[:token])
      end

      def create(data = {})
        yield data if block_given?
        post(data)
      end
    end
  end
end
