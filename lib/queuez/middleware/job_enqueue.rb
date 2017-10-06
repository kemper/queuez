module Queuez
  module Middleware
    class JobEnqueue
      def call(options)
        attributes = options.slice(:content, :queue, :shard)
        QueuezJob.create!(attributes)
      end
    end
  end
end
