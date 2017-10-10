module Queuez
  module Middleware
    class DequeueProducedWork
      def call(options)
        config = Queuez.config_for(options[:queue])
        shard = config.internal_queue.pop
        options[:shard] = shard
        yield options
      end
    end
  end
end
