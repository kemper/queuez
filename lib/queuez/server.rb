module Queuez
  class Server
    def initialize(config)
      @config = config
      @thread_id = nil
    end

    def start_async
      @thread_id = Thread.new do
        start
      end
    end

    def start
      loop do
        @config.producer_middleware.call({})
        sleep config.production_delay
      end
    end
  end
end
