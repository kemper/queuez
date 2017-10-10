module Queuez
  class Server
    attr_reader :config, :producer_thread, :consumer_thread

    def initialize(config)
      @config = config
      @producer_thread = nil
      @consumer_thread = nil
    end

    def start_async
      start_producer
      start_consumer
    end

    def start_producer
      @producer_thread = Thread.new do
        begin
          run_producer
        rescue Exception => e
          puts [e.message] + e.backtrace
        end
      end
    end

    def start_consumer
      @consumer_thread = Thread.new do
        begin
          run_consumer
        rescue Exception => e
          puts [e.message] + e.backtrace
        end
      end
    end

    #TODO: replace with something that supervises
    def run_producer
      loop do
        config.get_producer_middleware.call({queue: config.queue})
        sleep config.production_delay
      end
    end

    #TODO: replace with something that supervises
    def run_consumer
      loop do
        config.get_consumer_middleware.call({queue: config.queue})
        sleep config.consumer_delay
      end
    end

    def stop
      Thread.kill(producer_thread)
      Thread.kill(consumer_thread)
    end
  end
end
