module EmmyHttp
  class Client::Monitor
    using EventObject
    
    attr_accessor :logger

    def bind(op)
      @operation = op

      # operation events

      op.on :init do
        logger.debug "connected"
      end

      op.on :head do
        logger.debug "headers received"
      end

      op.on :success do |response, operation, conn|
        logger.info("request success with status #{response.status}")
      end

      op.on :error do |message|
        logger.error(message)
      end

      # client events

      op.adapter.client.on :change do |state, client|
        logger.debug "change state to #{state}"
      end

    end

    #<<<
  end
end
