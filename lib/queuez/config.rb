module Queuez
  class Config
    def initialize
      @client_middleware = Queuez::MiddlewareChain.new
      @producer_middleware = Queuez::MiddlewareChain.new
      @consumer_middleware = Queuez::MiddlewareChain.new
      @queues = {}
    end

    def client_middleware
      yield @client_middleware
    end

    def producer_middleware
      yield @producer_middleware
    end

    def consumer_middleware
      yield @consumer_middleware
    end

    def register_queue(name, klazz)
      @queues[name.to_s] = klazz
    end

    def worker_for(queue_name)
      @queues[queue_name.to_s]
    end

    def get_client_middleware
      @client_middleware
    end

    def get_producer_middleware
      @producer_middleware
    end

    def get_consumer_middleware
      @consumer_middleware
    end
  end
end
