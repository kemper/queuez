module Queuez
  class Server
    attr_reader :config, :producer_thread_id, :consumer_thread_id

    def initialize(config)
      @config = config
      @producer_thread_id = nil
      @consumer_thread_id = nil
    end

    def start_async
      puts "start_async"
      @producer_thread_id = Thread.new do
        begin
          start_producer
        rescue Exception => e
          puts [e.message] + e.backtrace
        end
      end
      @consumer_thread_id = Thread.new do
        begin
          start_consumer
        rescue Exception => e
          puts [e.message] + e.backtrace
        end
      end
    end

    #TODO: replace with something that supervises
    def start_producer
      puts "start producer"
      loop do
        puts "about to call producer middleware"
        config.get_producer_middleware.call({queue: config.queue})
        print config.production_delay
        sleep config.production_delay
      end
    end

    #TODO: replace with something that supervises
    def start_consumer
      puts "start consumer"
      loop do
        puts "about to call producer middleware"
        config.get_consumer_middleware.call({queue: config.queue})
        print config.consumer_delay
        sleep config.consumer_delay
      end
    end
  end
end
