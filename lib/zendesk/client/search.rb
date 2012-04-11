module Zendesk
  class Client
    module Search
      def search(*args)
        SearchTicketsCollection.new(self, *args)
      end
    end

    class SearchTicketsCollection < Collection
      def initialize(client, *args)
        super(client, :search, *args)
      end
    end
  end
end