module Queuez
  module Middleware
    class EnqueueProducedWork
      def call(options)
        config = Queuez.config_for(options[:queue])
        config.internal_queue << options[:shard]
        yield options
      end
    end
  end
end
