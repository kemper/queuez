module Queuez
  class Config
    attr_accessor :worker_class, :production_delay, :queue, :internal_queue, :consumer_delay

    def initialize
      @client_middleware = Queuez::MiddlewareChain.new
      @producer_middleware = Queuez::MiddlewareChain.new
      @consumer_middleware = Queuez::MiddlewareChain.new
      @internal_queue = SizedQueue.new(20)
      @worker_class = nil
      @production_delay = 1
      @consumer_delay = 0
      @queue = nil
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
