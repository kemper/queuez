module Queuez
  module Middleware
    class DequeueProducedWork
      def call(options)
        puts "dequeue work called"
        config = Queuez.config_for(options[:queue])
        shard = config.internal_queue.pop
        options[:shard] = shard
        puts "Shard #{shard}"
        yield options
      end
    end
  end
end
