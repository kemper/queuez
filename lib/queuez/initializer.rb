module Queuez
  class Initializer
    attr_reader :servers

    def initialize
      @servers = []
    end

    #TODO: doesn't make sense for client middleware to be at this level
    def initialize!(config_hash)
      config_hash[:queues].each do |queue_config|
        @servers << build_server(queue_config)
      end
    end

    def build_server(queue_config)
      server = nil 

      Queuez.configure(queue_config[:name]) do |config|
        config.client_middleware do |chain|
          chain.add(Queuez::Middleware::CreateBackgroundJob)
        end
        config.producer_middleware do |chain|
          chain.add(Queuez::Middleware::ProduceWork)
          chain.add(Queuez::Middleware::EnqueueProducedWork)
        end
        config.consumer_middleware do |chain|
          chain.add(Queuez::Middleware::DequeueProducedWork)
          chain.add(Queuez::Middleware::JobWorker)
        end
        server = Queuez::Server.new(config)
      end

      server
    end

    def start_all
      servers.each { |s| s.start_async }
    end

    def stop_all
      servers.each { |s| s.stop }
    end
  end
end
