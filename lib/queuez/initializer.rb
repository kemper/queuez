module Queuez
  class Initializer
    #TODO: doesn't make sense for client middleware to be at this level
    def initialize!(config)
      config[:queues].each do |queue_config|
        Queuez.configure(queue_config[:name]) do |config|
          config.client_middleware do |chain|
            chain.add(Queuez::Middleware::JobEnqueue)
          end
          config.producer_middleware do |chain|
            chain.add(Queuez::Middleware::ProduceWork)
            chain.add(Queuez::Middleware::EnqueueProducedWork)
          end
          config.consumer_middleware do |chain|
            chain.add(Queuez::Middleware::DequeueProducedWork)
            chain.add(Queuez::Middleware::JobWorker)
          end

          Queuez::Server.new(config).start_async
        end
      end
    end
  end
end
