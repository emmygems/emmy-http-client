module EmmyHttp
  class Client::Adapter
    include EmmyHttp::Adapter

    attr_accessor :operation
    attr_accessor :client

    def delegate=(operation)
      @operation = operation
      @client = Client::Client.new(operation.request, self)
      # if already connected
      if operation.connection
        client.initialize_connection(operation.connection)
        client.connect
      end
    end

    def to_a
      client.to_a
    end

    #<<<
  end
end
