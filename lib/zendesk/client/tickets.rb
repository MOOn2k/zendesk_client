module Zendesk
  class Client
    module Tickets
      # @zendesk.tickets
      # @zendesk.tickets(123)
      def tickets(*args)
        TicketsCollection.new(self, *args)
      end
    end

    class TicketsCollection < Collection
      # TODO: document all the fields
      def initialize(client, *args)
        super(client, :ticket, *args)
      end

      def views
        @query[:path] = "/rules"
        self
      end

      def create(data={})
        create_files(data) if data[:attachments]
        super(data)
      end

      # TODO: @zendesk.ticket(123).public_comment({ ... })
      # TODO: @zendesk.ticket(123).private_comment({ ... })

      private

      def create_files(data)
        token = nil
        data.delete(:attachments).each do |name|
          token = @client.attachments.create(:filename => name, :token => token)[:token]
        end
        data[:uploads] = token
      end
    end
  end
end
