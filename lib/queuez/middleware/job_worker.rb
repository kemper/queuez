module Queuez
  module Middleware
    class JobWorker
      def call(options)
        worker_class = Queuez.worker_for(options[:queue])
        job = QueuezJob.where(shard: options[:shard]).first
        options[:job] = job
        worker_class.new.work(options)
      end
    end
  end
end
